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

module type S = sig
  val is_computed: Kernel_function.t -> bool
  val set: Kernel_function.t -> bool -> unit
end

module Mem_access: S
module Div_mod: S
module Shift: S
module Signed_overflow: S
module Signed_downcast: S
module Unsigned_overflow: S
module Unsigned_downcast: S
module Float_to_int: S
module Called_precond: S

val emitter: Emitter.t

val precond_status: Db.RteGen.status_accessor
val shift_status: Db.RteGen.status_accessor
val div_mod_status: Db.RteGen.status_accessor
val mem_access_status: Db.RteGen.status_accessor
val float_to_int_status: Db.RteGen.status_accessor
val signed_overflow_status: Db.RteGen.status_accessor
val signed_downcast_status: Db.RteGen.status_accessor
val unsigned_overflow_status: Db.RteGen.status_accessor
val unsigned_downcast_status: Db.RteGen.status_accessor

val all_status: Db.RteGen.status_accessor list

(*
  Local Variables:
  compile-command: "make -C ../../.."
  End:
 *)
