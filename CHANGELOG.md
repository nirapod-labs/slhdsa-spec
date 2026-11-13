# Changelog

## 0.1.0 (2026-11-13)

First release.

- FIPS 205: the twelve parameter sets, Algorithms 1 to 25, addresses and
  compressed addresses, the SHA2 and SHAKE instantiations of section 11,
  pure and pre-hash signing with twelve pre-hash functions, and the
  probabilistic interface `SLH_DSA`.
- Validation theories for Table 2, Algorithms 1 to 4, the address layout and
  the message framing of section 10.2.
- The byte interface to FIPS 202 and MGF1 of RFC 8017; SHA-2 and HMAC
  vendored from nirapod-sha2 v0.1.0.
- `make check`, checked with EasyCrypt r2026.10.
