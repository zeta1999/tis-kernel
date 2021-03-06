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
(*  This file is part of Frama-C.                                         *)
(*                                                                        *)
(*  Copyright (C) 2007-2015                                               *)
(*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
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

(** Functional sets of [Cvalue.Model.t], currently implemented as lists
    without repetition. *)

type t

val pretty : Format.formatter -> t -> unit

(** Creation *)
val empty : t
val singleton : Cvalue.Model.t -> t
val of_list : Cvalue.Model.t list -> t

(** Information *)
val is_empty : t -> bool
val length : t -> int

(** Adding elements *)
val add : Cvalue.Model.t -> t -> t
exception Unchanged
val merge_into : t -> into:t -> t (** Raise [Unchanged] if the first set was
                                      already included in [into] *)
val merge : t -> t -> t
(** Merge the two sets together. Has a better complexity if the first state
    has less elements than the second. *)

(** Iterators *)
val fold : ('a -> Cvalue.Model.t -> 'a) -> 'a -> t -> 'a
val iter : (Cvalue.Model.t -> unit) -> t -> unit
val exists : (Cvalue.Model.t -> bool) -> t -> bool
val map: ((Cvalue.Model.t) -> (Cvalue.Model.t)) -> t -> t

val reorder: t -> t
(** Invert the order in which the states are iterated over *)

(** Export *)
val join : t -> Cvalue.Model.t
val narrow : t -> t -> t
val narrow_list: t list -> t

val to_list: t -> Cvalue.Model.t list


(*
Local Variables:
compile-command: "make -C ../../../.."
End:
*)
