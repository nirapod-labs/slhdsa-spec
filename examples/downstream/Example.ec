(*
 * SPDX-FileCopyrightText: 2026 H.M. Yousuf and Rifat Ahmed
 * SPDX-License-Identifier: CC0-1.0 OR Apache-2.0
 *
 * Example.ec
 * ==========
 *
 * A theory of another project that uses the specification. Its
 * easycrypt.project maps theories/ to the namespace SLHDSA and supplies the
 * dependencies, as README.md ("Using it") describes.
 * `make check-example` compiles this file.
 *)

require import AllCore List.
from SLHDSA require import Bytes FIPS205_Params FIPS205_External.

(* Algorithm 22, lines 1 to 3: a context longer than 255 bytes is rejected. *)
lemma slh_sign_long_ctx (p : params) (msg ctx sk : bytes) (addrnd : bytes option) :
  255 < size ctx => slh_sign p msg ctx sk addrnd = None.
proof. by move=> long; rewrite /slh_sign long. qed.

(* Algorithm 24 rejects such a context too. *)
lemma slh_verify_long_ctx (p : params) (msg sig ctx pk : bytes) :
  255 < size ctx => !slh_verify p msg sig ctx pk.
proof. by move=> long; rewrite /slh_verify long. qed.
