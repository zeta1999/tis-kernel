(**************************************************************************)
(*                                                                        *)
(*  This file is part of TrustInSoft Kernel.                              *)
(*                                                                        *)
(*  TrustInSoft Kernel is a fork of Frama-C. All the differences are:     *)
(*    Copyright (C) 2016-2017 TrustInSoft                                 *)
(*                                                                        *)
(*  TrustInSoft Kernel is released under GPLv2                            *)
(*                                                                        *)
(**************************************************************************)

(**************************************************************************)
(*                                                                        *)
(*  This file is part of WP plug-in of Frama-C.                           *)
(*                                                                        *)
(*  Copyright (C) 2007-2015                                               *)
(*    CEA (Commissariat a l'energie atomique et aux energies              *)
(*         alternatives)                                                  *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
(*                                                                        *)
(**************************************************************************)

(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require bool.Bool.
Require int.Int.

Require Import Qedlib.

(** * remarks about two_power_nat *)
Remark two_power_nat_is_positive: forall n,
  (0 < two_power_nat n)%Z.
Proof.
  induction n. 
  (** base *) 
  + compute. auto.
  (** ind. *) 
  + rewrite two_power_nat_S.
    apply Zmult_lt_0_compat.
    omega.
    auto.
Qed.

Remark two_power_nat_plus: forall n m,
  (two_power_nat (n+m) = (two_power_nat n)*(two_power_nat m))%Z.
Proof.
  induction m.
  (replace (two_power_nat 0) with 1%Z by (compute;forward)).
  (replace (n + 0)%nat with n by (auto with zarith)).
  ring.
  rewrite two_power_nat_S.
  replace (n + S m)%nat with (S(n+m)) by (auto with zarith).
  rewrite two_power_nat_S.
  rewrite IHm.
  ring.
Qed.
						      
(** * C-Integer bounds * **)

(** ** bounds are inlined into prover files ** **)

(** * C-Integer Ranges *)

(* Why3 assumption *)
Definition is_uint8 (x:Z): Prop := (0%Z <= x)%Z /\ (x < 256%Z)%Z.

(* Why3 assumption *)
Definition is_sint8 (x:Z): Prop := ((-128%Z)%Z <= x)%Z /\ (x < 128%Z)%Z.

(* Why3 assumption *)
Definition is_uint16 (x:Z): Prop := (0%Z <= x)%Z /\ (x < 65536%Z)%Z.

(* Why3 assumption *)
Definition is_sint16 (x:Z): Prop := ((-32768%Z)%Z <= x)%Z /\ (x < 32768%Z)%Z.

(* Why3 assumption *)
Definition is_uint32 (x:Z): Prop := (0%Z <= x)%Z /\ (x < 4294967296%Z)%Z.

(* Why3 assumption *)
Definition is_sint32 (x:Z): Prop := ((-2147483648%Z)%Z <= x)%Z /\
  (x < 2147483648%Z)%Z.

(* Why3 assumption *)
Definition is_uint64 (x:Z): Prop := (0%Z <= x)%Z /\
  (x < 18446744073709551616%Z)%Z.

(* Why3 assumption *)
Definition is_sint64 (x:Z): Prop := ((-9223372036854775808%Z)%Z <= x)%Z /\
  (x < 9223372036854775808%Z)%Z.

Open Local Scope Z_scope.

Definition to_range a b z := a + (z-a) mod (b-a).

Ltac simplify_to_range_unfolding :=
  repeat (rewrite Z.sub_0_r); repeat (rewrite Z.add_0_l); repeat (rewrite Z.sub_opp_r).
    
Lemma is_to_range: forall a b z, a<b -> a <= to_range a b z < b.
Proof.
  intros.
  unfold to_range.
  assert (Q : b-a > 0) ; auto with zarith.
  generalize (Z_mod_lt (z-a) (b-a) Q).
  intro R.
  auto with zarith.
Qed.


(* Why3 goal *)
Definition to_uint8: Z -> Z.
exact (to_range 0 256).
Defined.

(* Why3 goal *)
Definition to_sint8: Z -> Z.
exact (to_range (-128) 128).
Defined.

(* Why3 goal *)
Definition to_uint16: Z -> Z.
exact (to_range 0 65536).
Defined.

(* Why3 goal *)
Definition to_sint16: Z -> Z.
exact (to_range (-32768) 32768).
Defined.

(* Why3 goal *)
Definition to_uint32: Z -> Z.
exact (to_range 0 4294967296).
Defined.

(* Why3 goal *)
Definition to_sint32: Z -> Z.
exact (to_range (-2147483648) 2147483648).
Defined.

(* Why3 goal *)
Definition to_uint64: Z -> Z.
exact (to_range 0 18446744073709551616).
Defined.

(* Why3 goal *)
Definition to_sint64: Z -> Z.
exact (to_range (-9223372036854775808) 9223372036854775808).
Defined.

(* Why3 goal *)
Definition two_power_abs: Z -> Z.
exact (fun n => two_power_nat (Z.abs_nat n)).
Defined.

(* Why3 goal *)
Lemma two_power_abs_is_positive : forall (n:Z), (0%Z < (two_power_abs n))%Z.
Proof.
  intros n.
  unfold two_power_abs.
  apply two_power_nat_is_positive.
Qed.

(* Why3 goal *)
Lemma two_power_abs_plus_pos : forall (n:Z) (m:Z), (0%Z <= n)%Z ->
  ((0%Z <= m)%Z ->
  ((two_power_abs (n + m)%Z) = ((two_power_abs n) * (two_power_abs m))%Z)).
Proof.
  intros n m h1 h2.
  unfold two_power_abs.
  replace (Z.abs_nat (n + m)) with ((Z.abs_nat n) + (Z.abs_nat m))%nat.
  + rewrite two_power_nat_plus. trivial.
  + rewrite Zabs2Nat.inj_add by omega. trivial.
Qed.

(* Why3 goal *)
Lemma two_power_abs_plus_one : forall (n:Z), (0%Z <= n)%Z ->
  ((two_power_abs (n + 1%Z)%Z) = (2%Z * (two_power_abs n))%Z).
Proof.
  intros n h1.
  rewrite two_power_abs_plus_pos by omega.
  replace (two_power_abs 1) with 2%Z.
  + ring.
  + unfold two_power_abs.
    compute. trivial.
Qed.

(* Why3 assumption *)
Definition is_uint (n:Z) (x:Z): Prop := (0%Z <= x)%Z /\
  (x < (two_power_abs n))%Z.

(* Why3 assumption *)
Definition is_sint (n:Z) (x:Z): Prop := ((-(two_power_abs n))%Z <= x)%Z /\
  (x < (two_power_abs n))%Z.

(* Why3 goal *)
Definition to_uint: Z -> Z -> Z.
exact (fun n => to_range 0 (two_power_abs n)).
Defined.

Ltac to_uint to_uintN := unfold to_uint; unfold to_uintN; f_equal.

Remark to_uint_8 : to_uint8 = to_uint 8%Z.
Proof. to_uint to_uint8.
Qed.

Remark to_uint_16 : to_uint16 = to_uint 16%Z.
Proof. to_uint to_uint16.
Qed.
					
Remark to_uint_32 : to_uint32 = to_uint 32%Z.
Proof. to_uint to_uint32.
Qed.
					
Remark to_uint_64 : to_uint64 = to_uint 64%Z.
Proof. to_uint to_uint64.
Qed.
					
(* Why3 goal *)
Definition to_sint: Z -> Z -> Z.
exact (fun n => to_range (-two_power_abs n) (two_power_abs n)).
Defined.

Ltac to_sint to_sintN := unfold to_sint; unfold to_sintN; f_equal.

Remark to_sint_8 : to_sint8 = to_sint 7%Z.
Proof. to_sint to_sint8.
Qed.

Remark to_sint_16 : to_sint16 = to_sint 15%Z.
Proof. to_sint to_sint16.
Qed.

Remark to_sint_32 : to_sint32 = to_sint 31%Z.
Proof. to_sint to_sint32.
Qed.

Remark to_sint_64 : to_sint64 = to_sint 63%Z.
Proof. to_sint to_sint64.
Qed.

(* Why3 goal *)
Lemma is_to_uint : forall (n:Z) (x:Z), (is_uint n (to_uint n x)).
Proof. 
  intros n x.
  apply is_to_range.
  apply two_power_abs_is_positive.
Qed.

(* Why3 goal *)
Lemma is_to_sint : forall (n:Z) (x:Z), (is_sint n (to_sint n x)).
Proof. 
  intros n x.
  apply is_to_range.
  generalize (two_power_abs_is_positive n); intro.
  omega.
Qed.

(** * C-Integer Conversions are in-range *)

Local Ltac to_range := intro x ; apply is_to_range ; omega.

(* Why3 goal *)
Lemma is_to_uint8 : forall (x:Z), (is_uint8 (to_uint8 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_sint8 : forall (x:Z), (is_sint8 (to_sint8 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_uint16 : forall (x:Z), (is_uint16 (to_uint16 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_sint16 : forall (x:Z), (is_sint16 (to_sint16 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_uint32 : forall (x:Z), (is_uint32 (to_uint32 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_sint32 : forall (x:Z), (is_sint32 (to_sint32 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_uint64 : forall (x:Z), (is_uint64 (to_uint64 x)).
Proof. to_range.
Qed.

(* Why3 goal *)
Lemma is_to_sint64 : forall (x:Z), (is_sint64 (to_sint64 x)).
Proof. to_range.
Qed.

(** * C-Integer Conversions are identity when in-range *)
Open Local Scope Z_scope.

Remark mod_kn_mod_n:  forall (k:Z) (n:Z) (x:Z), k>0 -> n>0 -> (x mod (k*n)) mod n = x mod n.
Proof.
  intros.
  rewrite (Zmod_eq_full x (k*n)).
  + rewrite <- Z.add_opp_r. rewrite Zopp_mult_distr_l.
    replace (- (x/(k*n)) * (k*n)) with (((-(x/(k*n))) * k) * n) by ring.
    apply Z_mod_plus_full.
  + assert (k*n > 0).
    { apply Zmult_gt_0_compat; trivial. }
    omega.
Qed.			       

Lemma id_to_range : forall a b x, a <= x < b -> to_range a b x = x.
Proof.
  intros a b x Range. unfold to_range.
  assert (Q : b-a > 0) ; auto with zarith.
  cut ((x-a) mod (b-a) = (x-a)). omega.
  apply Zmod_small. omega.
Qed.
  
Local Ltac id_range := intro x ; apply id_to_range ; omega.

(* Why3 goal *)
Lemma id_uint : forall (n:Z) (x:Z), (is_uint n x) <-> ((to_uint n x) = x).
Proof.
  intros n x; split.
  + apply id_to_range.
  + intro H; rewrite <- H. apply is_to_uint.
Qed.

(* Why3 goal *)
Lemma id_sint : forall (n:Z) (x:Z), (is_sint n x) <-> ((to_sint n x) = x).
Proof.
  intros n x; split.
  + apply id_to_range.
  + intro H; rewrite <- H. apply is_to_sint.
Qed.

(* Why3 goal *)
Lemma id_uint8 : forall (x:Z), (is_uint8 x) -> ((to_uint8 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_sint8 : forall (x:Z), (is_sint8 x) -> ((to_sint8 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_uint16 : forall (x:Z), (is_uint16 x) -> ((to_uint16 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_sint16 : forall (x:Z), (is_sint16 x) -> ((to_sint16 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_uint32 : forall (x:Z), (is_uint32 x) -> ((to_uint32 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_sint32 : forall (x:Z), (is_sint32 x) -> ((to_sint32 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_uint64 : forall (x:Z), (is_uint64 x) -> ((to_uint64 x) = x).
Proof. id_range.
Qed.

(* Why3 goal *)
Lemma id_sint64 : forall (x:Z), (is_sint64 x) -> ((to_sint64 x) = x).
Proof. id_range.
Qed.

(** * C-Integer Conversions are projections *)
    
Local Ltac proj := intro x ; apply id_to_range ; apply is_to_range ; omega.

(* Why3 goal *)
Lemma proj_uint : forall (n:Z) (x:Z), ((to_uint n (to_uint n x)) = (to_uint n
  x)).
Proof.
  intros n x. apply id_to_range. 
  unfold to_uint. apply is_to_range. apply two_power_abs_is_positive.
Qed.

(* Why3 goal *)
Lemma proj_sint : forall (n:Z) (x:Z), ((to_sint n (to_sint n x)) = (to_sint n
  x)).
Proof.
  intros n x. apply id_to_range. 
  unfold to_sint. apply is_to_range. 
  assert (0 < two_power_abs n).
  { apply two_power_abs_is_positive. }
  omega.
Qed.

(* Why3 goal *)
Lemma proj_uint8 : forall (x:Z), ((to_uint8 (to_uint8 x)) = (to_uint8 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_sint8 : forall (x:Z), ((to_sint8 (to_sint8 x)) = (to_sint8 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_uint16 : forall (x:Z),
  ((to_uint16 (to_uint16 x)) = (to_uint16 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_sint16 : forall (x:Z),
  ((to_sint16 (to_sint16 x)) = (to_sint16 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_uint32 : forall (x:Z),
  ((to_uint32 (to_uint32 x)) = (to_uint32 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_sint32 : forall (x:Z),
  ((to_sint32 (to_sint32 x)) = (to_sint32 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_uint64 : forall (x:Z),
  ((to_uint64 (to_uint64 x)) = (to_uint64 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_sint64 : forall (x:Z),
  ((to_sint64 (to_sint64 x)) = (to_sint64 x)).
Proof. proj.
Qed.

(* Why3 goal *)
Lemma proj_su : forall (n:Z) (x:Z), ((to_sint n (to_uint n x)) = (to_uint n
  x)).
Proof.
  intros n x; unfold to_uint; unfold to_sint; unfold to_range; simplify_to_range_unfolding.
  generalize (two_power_abs_is_positive n).
  pose (n2:=(two_power_abs n)); fold n2.
  intros.
  replace (n2 + n2) with (2*n2) by (auto with zarith).
  replace ((x mod n2 + n2) mod (2 * n2)) with (x mod n2 + n2).
  + replace (- n2 + (x mod n2 + n2)) with (x mod n2) by ring.
    trivial.
  + symmetry. apply Zmod_small.
    assert (0 <= x mod n2 < n2).
    { apply Z_mod_lt; omega. }
    omega.
Qed.

(* Why3 goal *)
Lemma incl_su : forall (n:Z) (x:Z), (is_uint n x) -> (is_sint n x).
Proof.
  intros n x.
  rewrite id_uint; intro H; rewrite <- H.
  rewrite id_sint; apply proj_su.
Qed.

(* Why3 goal *)
Lemma proj_su_uint : forall (n:Z) (m:Z) (x:Z), (0%Z <= n)%Z ->
  ((0%Z <= m)%Z -> ((to_sint (m + n)%Z (to_uint n x)) = (to_uint n x))).
Proof.
  intros n m x Posn POSm; unfold to_uint; unfold to_sint; unfold to_range.
  repeat (rewrite Z.sub_0_r); rewrite Z.add_0_l; repeat (rewrite Z.sub_opp_r).
  generalize (two_power_abs_is_positive n).
  generalize (two_power_abs_is_positive m).
  generalize (two_power_abs_is_positive (m+n)).

  rewrite two_power_abs_plus_pos by omega.
  pose (n2:=(two_power_abs n)); fold n2.
  pose (m2:=(two_power_abs m)); fold m2.
  intros.

  replace (m2*n2 + m2*n2) with (2*(m2*n2)) by (auto with zarith).
  replace ((x mod n2 + (m2*n2)) mod (2*(m2*n2))) with (x mod n2 + (m2*n2)).
  + omega.
  + symmetry. apply Zmod_small.
    pose (r:=(x mod n2)); fold r.
    assert (0 <= r < n2).
    { apply Z_mod_lt; omega. }
    split.
    * omega.
    * replace (2*(m2*n2)) with (m2*n2 + m2*n2) by (auto with zarith).
      rewrite <- Z.add_lt_mono_r.
      pose (mn:=(m2 * n2)); fold mn.
      assert (n2 <= mn).
      { replace n2 with (1*n2) by auto with zarith.
	      unfold mn. 
        apply Int.CompatOrderMult; omega. }
      destruct H2. omega.
Qed.

(* Why3 goal *)
Lemma proj_su_sint : forall (n:Z) (m:Z) (x:Z), (0%Z <= n)%Z ->
  ((0%Z <= m)%Z -> ((to_sint n (to_uint (m + (n + 1%Z)%Z)%Z x)) = (to_sint n
  x))).
Proof.
  intros n m x POSn POSm; unfold to_uint; unfold to_sint; unfold to_range.
  repeat (rewrite Z.sub_0_r); rewrite Z.add_0_l; repeat (rewrite Z.sub_opp_r).
  generalize (two_power_abs_is_positive n).
  generalize (two_power_abs_is_positive m).
  generalize (two_power_abs_is_positive (m + (n + 1))).
 
  rewrite two_power_abs_plus_pos by omega.
  rewrite two_power_abs_plus_one by omega.
  pose (n2:=(two_power_abs n)); fold n2.
  pose (m2:=(two_power_abs m)); fold m2.
  intros.

  replace (n2 + n2) with (2*n2) by (auto with zarith).
  symmetry.
  rewrite <- (mod_kn_mod_n m2 ) by omega.
  rewrite <- Z.add_mod_idemp_l by omega.
  rewrite mod_kn_mod_n by omega.
  trivial.
Qed.

(* Why3 goal *)
Lemma proj_int8 : forall (x:Z), ((to_sint8 (to_uint8 x)) = (to_sint8 x)).
Proof.
  intros x.
  rewrite to_sint_8. rewrite to_uint_8.
  replace 8 with (0+(7+1)) by (auto with zarith). 
  apply proj_su_sint; (auto with zarith).
Qed.

(* Why3 goal *)
Lemma proj_int16 : forall (x:Z), ((to_sint16 (to_uint16 x)) = (to_sint16 x)).
Proof.
  intros x.
  rewrite to_sint_16. rewrite to_uint_16.
  replace 16 with (0+(15+1)) by (auto with zarith). 
  apply proj_su_sint; (auto with zarith).
Qed.

(* Why3 goal *)
Lemma proj_int32 : forall (x:Z), ((to_sint32 (to_uint32 x)) = (to_sint32 x)).
Proof.
  intros x.
  rewrite to_sint_32. rewrite to_uint_32.
  replace 32 with (0+(31+1)) by (auto with zarith). 
  apply proj_su_sint; (auto with zarith).
Qed.

(* Why3 goal *)
Lemma proj_int64 : forall (x:Z), ((to_sint64 (to_uint64 x)) = (to_sint64 x)).
Proof.
  intros x.
  rewrite to_sint_64. rewrite to_uint_64.
  replace 64 with (0+(63+1)) by (auto with zarith). 
  apply proj_su_sint; (auto with zarith).
Qed.

(* Why3 goal *)
Lemma proj_us_uint : forall (n:Z) (m:Z) (x:Z), (0%Z <= n)%Z ->
  ((0%Z <= m)%Z -> ((to_uint (n + 1%Z)%Z (to_sint (m + n)%Z
  x)) = (to_uint (n + 1%Z)%Z x))).
Proof.
  intros n m x POSn POSm; unfold to_uint; unfold to_sint; unfold to_range.
  repeat (rewrite Z.sub_0_r); repeat (rewrite Z.add_0_l); repeat (rewrite Z.sub_opp_r).
  generalize (two_power_abs_is_positive n).
  generalize (two_power_abs_is_positive m).
  rewrite two_power_abs_plus_one by omega.
  rewrite two_power_abs_plus_pos by omega.
  pose (n2:=(two_power_abs n)); fold n2.
  pose (m2:=(two_power_abs m)); fold m2.
  intros.
  replace (m2*n2 + m2*n2) with (2*(m2*n2)) by (auto with zarith).
  rewrite Z.add_opp_l.
  symmetry.
  rewrite <- (mod_kn_mod_n m2) by omega.
  replace (m2 * (2 * n2)) with (2 * (m2 * n2)) by ring.
  pose (mn:=(m2*n2)); fold mn.
  replace x with ((x+mn)-mn) by (auto with zarith).
  replace (x + mn - mn + mn) with (x + mn) by (auto with zarith).
  rewrite <- Zminus_mod_idemp_l. 
  unfold mn.
  replace (2 * (m2 * n2)) with (m2 * (2 * n2)) by ring.
  rewrite mod_kn_mod_n by omega.
  trivial.
Qed.

Remark two_power_abs_increase: forall (n:Z), 0 <= n -> two_power_abs n < two_power_abs (n +1).
Proof.
  intros.
  generalize (two_power_abs_is_positive n); intro h.
  rewrite two_power_abs_plus_one; omega.
Qed.

Require Import Qedlib.
(* Why3 goal *)
Lemma incl_uint : forall (n:Z) (x:Z) (i:Z), (0%Z <= n)%Z -> ((0%Z <= i)%Z ->
  ((is_uint n x) -> (is_uint (n + i)%Z x))).
Proof.
  intros n x i h1 h2 h3.
  apply Qedlib.Z_induction_rank with (m:=0) (n := i) ; auto with zarith.
  { replace (n + 0) with n by ring; auto. }
  intro; unfold is_uint; intros h10 h11.
  split.
  + omega.
  + replace (n + (n0 + 1)) with ((n + n0) + 1) by ring.
    pose (m :=(n + n0)); fold m; fold m in h11.
    assert (two_power_abs m < two_power_abs (m + 1)).
    { assert (0 <= m) by (unfold m; omega).
      clear h11 h2 x h3 i h1 h10.
      apply two_power_abs_increase; auto.
    }
    omega.
Qed.

(* Why3 goal *)
Lemma incl_sint : forall (n:Z) (x:Z) (i:Z), (0%Z <= n)%Z -> ((0%Z <= i)%Z ->
  ((is_sint n x) -> (is_sint (n + i)%Z x))).
Proof.
  intros n x i h1 h2 h3.
  apply Qedlib.Z_induction_rank with (m:=0) (n := i) ; auto with zarith.
  { replace (n + 0) with n by ring; auto. }
  intro; unfold is_sint; intros h10 h11.
  replace (n + (n0 + 1)) with ((n + n0) + 1) by ring.
  pose (m :=(n + n0)); fold m; fold m in h11.
  assert (0 <= m).
  { unfold m; omega. }
  generalize (two_power_abs_increase m); intro.
  omega.
Qed.

(* Why3 goal *)
Lemma incl_int : forall (n:Z) (x:Z) (i:Z), (0%Z <= n)%Z -> ((0%Z <= i)%Z ->
  ((is_uint n x) -> (is_sint (n + i)%Z x))).
Proof.
  intros n x i h1 h2 h3.
  unfold is_sint; unfold is_uint in h3.
  apply Qedlib.Z_induction_rank with (m:=0) (n := i) ; auto with zarith.
  { replace (n + 0) with n by ring; omega. }
  intro.
  replace (n + (n0 + 1)) with ((n + n0) + 1) by ring.
  pose (m :=(n + n0)); fold m; intros.
  assert (0 <= m).
  { unfold m; omega. }
  generalize (two_power_abs_increase m); intro.
  omega.
Qed.

Require Import Zbits.
  
(* Why3 goal *)
Definition lnot: Z -> Z.
  exact (lnot).
Defined.

(* Why3 goal *)
Definition land: Z -> Z -> Z.
  exact (land).
Defined.

(* Why3 goal *)
Definition lxor: Z -> Z -> Z.
  exact (lxor).
Defined.

(* Why3 goal *)
Definition lor: Z -> Z -> Z.
  exact (lor).
Defined.

(* Why3 goal *)
Definition lsl: Z -> Z -> Z.
  exact (lsl).
Defined.

(* Why3 goal *)
Definition lsr: Z -> Z -> Z.
  exact (lsr).
Defined.

(* Why3 goal *)
Definition bit_testb: Z -> Z -> bool.
exact (bit_testb).
Defined.

(* Why3 goal *)
Definition bit_test: Z -> Z -> Prop.
exact (fun x i => (bit_testb x i) = true).
Defined.

(* Unused content named is_uint8_pos
intros x h.
red in h.
intuition.
Qed.
 *)
(* Unused content named is_uint16_pos
intros x h.
red in h.
intuition.
Qed.
 *)
(* Unused content named is_uint32_pos
intros x h.
red in h.
intuition.
Qed.
 *)
(* Unused content named is_uint64_pos
intros x h.
red in h.
intuition.
Qed.
 *)
(** * Tacticals. *)
Require Import Qedlib.

Fixpoint Cst_nat n := 
  match n with O => true | S c => Cst_nat c 
  end.
Fixpoint Cst_pos p := 
  match p with xH => true | xI c | xO c => Cst_pos c 
  end.
Fixpoint Cst_N n := 
  match n with N0 => true | Npos c => Cst_pos c 
  end.
Definition Cst_Z x := 
  match x with Z0 => true | Zpos c | Zneg c => Cst_pos c 
  end.
Ltac COMPUTE e :=
  let R := fresh in pose (R := e); fold R; compute in R; unfold R; clear R.
Ltac COMPUTE_HYP h e :=
  let R := fresh in pose (R := e); fold R in h; compute in R; unfold R in h; clear R.
Ltac GUARD cst e := 
  let E := fresh in pose (E := cst e); compute in E; 
  match goal with
    | [ E:=true |- _] => clear E
  end.
Ltac COMPUTE1 f cst := 
  match goal with 
   | [ |- context[f ?e] ]      => GUARD cst e; COMPUTE (f e)
   | [ H:=context[f ?e] |- _ ] => GUARD cst e; COMPUTE_HYP H (f e)
   | [ H: context[f ?e] |- _ ] => GUARD cst e; COMPUTE_HYP H (f e)
  end.
Ltac COMPUTE2 f cst1 cst2 := 
  match goal with  
   | [ |- context[f ?e1 ?e2] ]     => GUARD cst1 e1; GUARD cst2 e2; COMPUTE (f e1 e2)
   | [ H:=context[f ?e1 ?e2] |- _] => GUARD cst1 e1; GUARD cst2 e2; COMPUTE_HYP H (f e1 e2)
   | [ H: context[f ?e1 ?e2] |- _] => GUARD cst1 e1; GUARD cst2 e2; COMPUTE_HYP H (f e1 e2)
  end.
Ltac COMPUTE2AC f cst tac := 
  match goal with  
   | [ |- context[f ?e1 (f ?e2 ?e3) ]] => GUARD cst e1; 
                                          first [ (GUARD cst e2; (replace (f e1 (f e2 e3)) with (f e3 (f e1 e2)) by (tac ; forward)); COMPUTE (f e1 e2))
						| (GUARD cst e3; (replace (f e1 (f e2 e3)) with (f e2 (f e1 e3)) by (tac ; forward)); COMPUTE (f e1 e3))]
   | [ |- context[f (f ?e3 ?e2) ?e1 ]] => GUARD cst e1; 
                                          first [ (GUARD cst e2; (replace (f (f e3 e2) e1) with (f e3 (f e2 e1)) by (tac ; forward)); COMPUTE (f e2 e1))
						| (GUARD cst e3; (replace (f (f e3 e2) e1) with (f e2 (f e3 e1)) by (tac ; forward)); COMPUTE (f e3 e1))]
   | [ H:=context[f ?e1 (f ?e2 ?e3) ] |- _] => GUARD cst e1; 
                                          first [ (GUARD cst e2; (replace (f e1 (f e2 e3)) with (f e3 (f e1 e2)) in H by (tac ; forward)); COMPUTE_HYP H (f e1 e2))
						| (GUARD cst e3; (replace (f e1 (f e2 e3)) with (f e2 (f e1 e3)) in H by (tac ; forward)); COMPUTE_HYP H (f e1 e3))]
   | [ H:=context[f (f ?e3 ?e2) ?e1 ] |- _] => GUARD cst e1; 
                                          first [ (GUARD cst e2; (replace (f (f e3 e2) e1) with (f e3 (f e2 e1)) in H by (tac ; forward)); COMPUTE_HYP H (f e2 e1))
						| (GUARD cst e3; (replace (f (f e3 e2) e1) with (f e2 (f e3 e1)) in H by (tac ; forward)); COMPUTE_HYP H (f e3 e1))]
   | [ H: context[f ?e1 (f ?e2 ?e3) ] |- _] => GUARD cst e1; 
                                          first [ (GUARD cst e2; (replace (f e1 (f e2 e3)) with (f e3 (f e1 e2)) in H by (tac ; forward)); COMPUTE (f e1 e2))
						| (GUARD cst e3; (replace (f e1 (f e2 e3)) with (f e2 (f e1 e3)) in H by (tac ; forward)); COMPUTE_HYP H (f e1 e3))]
   | [ H: context[f (f ?e3 ?e2) ?e1 ] |- _] => GUARD cst e1; 
                                          first [ (GUARD cst e2; (replace (f (f e3 e2) e1) with (f e3 (f e2 e1)) in H by (tac ; forward)); COMPUTE_HYP H (f e2 e1))
						| (GUARD cst e3; (replace (f (f e3 e2) e1) with (f e2 (f e3 e1)) in H by (tac ; forward)); COMPUTE_HYP H (f e3 e1))]
  end.
Ltac COMPUTE3 f cst1 cst2 cst3 := 
  match goal with  
   | [ |- context[f ?e1 ?e2 ?e3] ]      => GUARD cst1 e1; GUARD cst2 e2; GUARD cst3 e3; COMPUTE (f e1 e2 e3)
   | [ H:=context[f ?e1 ?e2 ?e3] |- _ ] => GUARD cst1 e1; GUARD cst2 e2; GUARD cst3 e3; COMPUTE_HYP H (f e1 e2 e3)
   | [ H: context[f ?e1 ?e2 ?e3] |- _ ] => GUARD cst1 e1; GUARD cst2 e2; GUARD cst3 e3; COMPUTE_HYP H (f e1 e2 e3)
  end.

(*

Require Import Bits. 
    
Ltac ring_tactic := ring.
  
Ltac rewrite_cst :=
  first [ COMPUTE Zopp Cst_Z 
        | COMPUTE Zsucc Cst_Z
        | COMPUTE Zpred Cst_Z
        | COMPUTE Zdouble_plus_one Cst_Z
        | COMPUTE Zdouble_minus_one Cst_Z
        | COMPUTE Zdouble Cst_Z
        | COMPUTE Zabs Cst_Z
	  
        | COMPUTE Zabs_N Cst_Z
        | COMPUTE Zabs_nat Cst_Z

        | COMPUTE Z_of_N Cst_N 
        | COMPUTE Z_of_nat Cst_nat
        | COMPUTE two_power_nat Cst_nat

        | COMPUTE2 Zminus Cst_Z Cst_Z
        | COMPUTE2 Zplus Cst_Z Cst_Z
        | COMPUTE2 Zmult Cst_Z Cst_Z

        | COMPUTE2AC Zplus Cst_Z ring_tactic
        | COMPUTE2AC Zmult Cst_Z ring_tactic
	  
        | COMPUTE to_uint8 Cst_Z
        | COMPUTE to_sint8 Cst_Z
        | COMPUTE to_uint16 Cst_Z
        | COMPUTE to_sint16 Cst_Z
        | COMPUTE to_uint32 Cst_Z
        | COMPUTE to_sint32 Cst_Z
        | COMPUTE to_uint64 Cst_Z
        | COMPUTE to_sint64 Cst_Z
        | COMPUTE3 to_range Cst_Z Cst_Z Cst_Z
	| COMPUTE1 zlnot Cst_Z
	| COMPUTE1 ZxHpos Cst_Z
	| COMPUTE1 ZxHpower Cst_Z
        ].

Remark rewrite_cst_example_1: forall x y, 1 + ((2 * x) * 3 + 2) = (3 * (2 * y)+ 2) + 1 -> 1 + (2 + (x * 2) * 3 ) = (2 + 3 * (y* 2)) + 1.
Proof.
  intros. repeat rewrite_cst. auto.
Qed.

Remark rewrite_cst_example_2: forall x: Z,
  x + zlnot (zlnot (0)) = x + Z_of_nat (ZxHpos 0).
Proof.
  rewrite_cst. intro. auto.
Qed.

*)
