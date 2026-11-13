<!--
SPDX-FileCopyrightText: 2026 H.M. Yousuf and Rifat Ahmed
SPDX-License-Identifier: CC0-1.0 OR Apache-2.0
-->

# slhdsa-spec

An EasyCrypt specification of SLH-DSA,
[FIPS 205](https://doi.org/10.6028/NIST.FIPS.205), meant as the reference
for functional-correctness proofs of SLH-DSA implementations.

Each algorithm is an EasyCrypt operator that cites its algorithm number and
the pseudocode lines it transcribes. Keys, signatures and messages are byte
strings, and every operator takes the parameter set as an argument.

## Coverage

- The twelve parameter sets of Table 2.
- Algorithms 1 to 25, addresses (Table 1) and compressed addresses (Table 3).
- Both instantiations of section 11: SHAKE256, and SHA-256/SHA-512 with HMAC
  and MGF1.
- Pure SLH-DSA and HashSLH-DSA, with the twelve pre-hash functions of the
  NIST hashAlgs arc.
- Deterministic and hedged signing, and a module `SLH_DSA` that samples the
  random values.

Not modelled: messages that are not whole bytes, the RBG failure paths of
Algorithms 21 and 22, and the MGF1 "mask too long" error, which FIPS 205
never reaches.

## Algorithms

| Alg. | Operator | Theory |
|---:|---|---|
| 1 | `gen_len2` | `FIPS205_Params` |
| 2–4 | `toInt`, `toByte`, `base_2b` | `FIPS205_Encoding` |
| 5–8 | `chain`, `wots_pkGen`, `wots_sign`, `wots_pkFromSig` | `FIPS205_WOTS` |
| 9–11 | `xmss_node`, `xmss_sign`, `xmss_pkFromSig` | `FIPS205_XMSS` |
| 12–13 | `ht_sign`, `ht_verify` | `FIPS205_Hypertree` |
| 14–17 | `fors_skGen`, `fors_node`, `fors_sign`, `fors_pkFromSig` | `FIPS205_FORS` |
| 18–20 | `slh_keygen_internal`, `slh_sign_internal`, `slh_verify_internal` | `FIPS205_Internal` |
| 21–25 | `slh_keygen`, `slh_sign`, `hash_slh_sign`, `slh_verify`, `hash_slh_verify` | `FIPS205_External` |

The section 4.1 functions (`PRF_msg`, `H_msg`, `PRF`, `F`, `H`, `T_l`) are
in `FIPS205_Hash`, addresses in `FIPS205_Address`, and the message framing
of section 10.2 in `FIPS205_External`. Each theory header says where its
form departs from the pseudocode: loops are folds, `while` loops run with
stated fuel, Algorithms 9 and 15 recurse on the list of heights, and
addresses are passed by value.

## Validation and evidence

The `validation/` theories check parts of the transcription against the
standard: Table 2 against its own formulas, Algorithms 1 to 4 on concrete
inputs, the address layout of Figures 2, 6 and 18, and the injectivity of
the section 10.2 framing.

- VERIFIED: every theory checks with no proof hole, and no theory of this
  project adds an axiom (`make check`).
- VERIFIED: the vendored SHA-2 and HMAC operators give the CAVP outputs on
  the 60 vectors of nirapod-sha2 v0.1.0.
- INFERRED: Algorithms 5 to 25 and the section 11 instantiations match
  FIPS 205, by review.
- UNKNOWN: the specification has not been run on ACVP vectors.

## Checking

Toolchain: EasyCrypt r2026.10 (`859766e`), Why3 1.8.2, Z3 4.16.0 and
4.13.4, CVC5 1.2.1.

```
make check JOBS=4
```

This verifies the vendored files against `vendor/SHA256SUMS`, scans for
`admit` and similar commands, compiles every theory in its own run with
`-no-eco`, compares the axioms in scope with `docs/axioms.txt`, and builds
`examples/downstream`.

## Using it

Map `theories/` to a namespace and provide the dependencies, as
`examples/downstream/easycrypt.project` does:

```
rdirs = SLHDSA:../../theories
idirs = SLHDSA:../../vendor/nirapod-sha2/proofs/spec
idirs = Jasmin:../../vendor/jasmin/eclib
idirs = JazzEC:../../vendor/formosa-libjade/proofs/arrays
idirs = ../../vendor/formosa-libjade/proofs/core/eclib
rdirs = CryptoSpecs:../../vendor/formosa-libjade/proofs/fips202/spec
```

Then `from SLHDSA require import FIPS205_External.`

In formosa-libjade the FIPS 202, array and `JWordList` theories are already
in place, so `theories/` should move to `proofs/slhdsa/spec` almost
unchanged. The `hash/` theories and the vendored SHA-2 theories are meant to
be replaced by libjade's own once it has SHA-2 and SHA-3 specifications.

## Dependencies

Vendored unchanged in `vendor/`:

- nirapod-sha2 v0.1.0: the SHA-2 and HMAC specification (Apache-2.0)
- formosa-libjade `589038b`: the FIPS 202 specification (CC0-1.0 OR Apache-2.0)
- Jasmin v2026.09.0: five files of `eclib` (MIT)

## Related work

[formosa-slhdsa](https://github.com/formosa-crypto/formosa-slhdsa) holds
the EasyCrypt security proof of SPHINCS+. This repository is the functional
specification of FIPS 205 that it lacks.

## Licence

CC0-1.0 OR Apache-2.0. Vendored files keep their own licences (`REUSE.toml`).
Citation: `CITATION.cff`.
