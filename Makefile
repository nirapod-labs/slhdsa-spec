# SPDX-FileCopyrightText: 2026 H.M. Yousuf and Rifat Ahmed
# SPDX-License-Identifier: CC0-1.0 OR Apache-2.0

EASYCRYPT ?= easycrypt
ECFLAGS   ?=
JOBS      ?= 1

OWN     := $(sort $(wildcard theories/*/*.ec validation/*.ec))
SHA2    := $(sort $(wildcard vendor/nirapod-sha2/proofs/spec/*.ec))
ECLIB   := $(sort $(wildcard vendor/jasmin/eclib/*.ec))
LIBJADE := $(sort $(shell find vendor/formosa-libjade -name '*.ec'))
ALL     := $(OWN) $(SHA2) $(ECLIB) $(LIBJADE)
CHECKS  := $(addprefix check/,$(ALL))

SHA256SUM := $(shell command -v sha256sum 2>/dev/null || echo "shasum -a 256")

.PHONY: check check-vendor scan check-theories check-axioms check-example clean $(CHECKS)

check: check-vendor scan check-theories check-axioms check-example

check-vendor:
	@cd vendor && $(SHA256SUM) -c --quiet SHA256SUMS && echo "check-vendor: PASS"

scan:
	@if grep -nwE 'admit|admitted|pragma|exit|fail' $(ALL); then \
	  echo "scan: FAIL"; exit 1; else echo "scan: PASS ($(words $(ALL)) files)"; fi

check-theories:
	@rm -rf .check/log && mkdir -p .check/log
	@$(MAKE) --no-print-directory -j$(JOBS) $(CHECKS)
	@echo "check-theories: PASS ($(words $(ALL)) files)"

check/vendor/jasmin/%:          PROVERS := -p Z3@4.13
check/vendor/formosa-libjade/%: PROVERS := -p Z3@4.13 -p CVC5@1.2

$(CHECKS): check/%:
	@log=.check/log/$(subst /,_,$*).txt; start=$$(date +%s); \
	if $(EASYCRYPT) compile -no-eco $(ECFLAGS) $(PROVERS) $* > $$log 2>&1; then \
	  echo "pass $* ($$(( $$(date +%s) - start )) s)"; \
	else echo "FAIL $*"; tr '\r' '\n' < $$log | grep -v '^\[.\] \[' | tail -20; exit 1; fi

check-axioms:
	@mkdir -p .check
	@{ for f in $(OWN); do echo "require $$(basename $$f .ec)."; done; echo "print axiom."; } > .check/Axioms.ec
	@$(EASYCRYPT) compile -no-eco $(ECFLAGS) .check/Axioms.ec > .check/axioms.out 2>&1 \
	  || { cat .check/axioms.out; echo "check-axioms: FAIL (EasyCrypt)"; exit 1; }
	@tr '\r' '\n' < .check/axioms.out | awk ' \
	  /^=+ .* =+$$/ { theory = $$2; next } \
	  /^axiom / { name = ($$2 ~ /^\[/) ? $$3 : $$2; sub(/:.*/, "", name); print theory, name }' \
	  | LC_ALL=C sort > .check/axioms.txt
	@for f in $(OWN) $(SHA2); do t=$$(basename $$f .ec); \
	  if grep -E "^$$t( |\.)" .check/axioms.txt; then echo "check-axioms: FAIL (axiom in $$t)"; exit 1; fi; \
	done
	@grep -v '^#' docs/axioms.txt | diff -u - .check/axioms.txt \
	  && echo "check-axioms: PASS ($$(wc -l < .check/axioms.txt | tr -d ' ') axioms, none in this project)"

check-example:
	@cd examples/downstream && $(EASYCRYPT) compile -no-eco $(ECFLAGS) Example.ec > ../../.check/example.out 2>&1 \
	  || { tr '\r' '\n' < ../../.check/example.out | grep -v '^\[.\] \['; echo "check-example: FAIL"; exit 1; }
	@echo "check-example: PASS"

clean:
	rm -rf .check
