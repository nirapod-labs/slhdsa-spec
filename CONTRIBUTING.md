# Contributing

Issues and pull requests are welcome.

A change to a theory should keep the link to the standard visible: the
algorithm number in the comment above the operator, and the pseudocode line
numbers next to the expressions that compute them. Where the form of an
operator departs from the pseudocode, say why in the theory header.

Before sending a change, run `make check` with the toolchain of README.md
and include the five PASS lines in the pull request. A new axiom, an
`admit`, or a change to `docs/axioms.txt` needs a reason in the
description.

Files under `vendor/` are copies of upstream files. Change them only by
updating to another upstream revision, together with `vendor/SHA256SUMS`
and the list in README.md.

By contributing you agree that your contribution is licensed under
CC0-1.0 OR Apache-2.0, as the rest of the project.
