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

let help_msg = "generates annotations for runtime error checking and \
                preconditions at call sites"

include Plugin.Register
    (struct
      let name = "rtegen"
      let shortname = "rte"
      let help = help_msg
    end)

(* enabling/disabling plugin *)
module Enabled =
  False
    (struct
      let option_name = "-rte"
      let help = "when on (off by default), " ^ help_msg
    end)

(* annotates division by zero (undefined behavior) *)
module DoDivMod =
  True
    (struct
      let option_name = "-rte-div"
      let help = "when on (default), annotate for modulo and division by zero"
    end)

(* annotates left and right shifts (undefined behavior) *)
module DoShift =
  True
    (struct
      let option_name = "-rte-shift"
      let help = "when on (default), annotate for left and right shifts by a value out of bounds"
    end)

(* annotates division by zero (undefined behavior) *)
module DoFloatToInt =
  True
    (struct
      let option_name = "-rte-float-to-int"
      let help = "when on (default), annotate casts from floating-point to \
                  integer"
    end)

(* annotates invalid memory access (undefined behavior) *)
module DoMemAccess =
  True
    (struct
      let option_name = "-rte-mem"
      let help = "when on (default), annotate for valid pointer or \
                  array access"
    end)

(* if DoAll is true: all other options become true, except for
   UnsignedOverflow, UnsignedDownCast and "PreConds"
   <=> only "true" runtime error and
       some implementation-defined behaviors assertions are generated *)
module DoAll =
  True
    (struct
      let option_name = "-rte-all"
      let help = "when on (by default), generate everything (supersedes all -rte-no-*)"
    end)

let () =
  DoAll.add_set_hook
    (fun _ b ->
       DoMemAccess.set b;
       DoDivMod.set b;
       DoFloatToInt.set b;
       Kernel.SignedOverflow.set b;
       Kernel.SignedDowncast.set b)

(* uses results of basic constant propagation in order to check
   validity / invalidity of generated assertions, emitting a status if possible
*)
module Trivial =
  False
    (struct
      let option_name = "-rte-trivial-annotations"
      let help = "generate annotations for constant expressions, even when \
                  they trivially hold"
      (* if on, evaluates constants in order to check if assertions
         are trivially true / false *)
    end)

(* For functions having an ACSL contract,
   generates a corresponding statement contract before each function's call
   statement (provided the call is not performed thorugh a function pointer).
*)
module DoCalledPrecond =
  False
    (struct
      let option_name = "-rte-precond"
      let help = "when on (off by default), generate assertions on function calls based on contracts"
    end)

(* emits a warning when an assertion generated by rte is clearly invalid
   (using constant folding, see ConstFold *)
module Warn =
  True
    (struct
      let option_name = "-rte-warn"
      let help = "when on (default), emits warning on broken asserts"
    end)

(* this option allows the user to select a set of functions on which
   the plug-in performs its jobs (and only those).
   By default all functions are annotated *)
module FunctionSelection =
  Kernel_function_set
    (struct
      let option_name = "-rte-select"
      let arg_name = "fun"
      let help = "select <fun> for analysis (default all functions)"
    end)

let warn ?source fmt = warning ?source ~current:true ~once:true fmt

(*
Local Variables:
compile-command: "make -C ../../.."
End:
*)
