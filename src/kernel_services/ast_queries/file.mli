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

(** Frama-c preprocessing and Cil AST initialization. *)

(** Whether a given preprocessor supports gcc options used in some
    configurations. *)
type cpp_opt_kind = Gnu | Not_gnu | Unknown

type file =
  | NeedCPP of string * string * cpp_opt_kind
  (** The first string is the filename of the [.c] to preprocess.
      The second one is the preprocessor command ([filename.c -o
      tempfilname.i] will be appended at the end).*)
  | NoCPP of string
  (** Already pre-processed file [.i] *)
  | External of string * string
  (** file that can be translated into a Cil AST through an external
      function, together with the recognized suffix. *)

include Datatype.S with type t = file

val new_file_type:
  string -> (string -> Cil_types.file * Cabs.file) -> unit
(** [new_file_type suffix func funcname] registers a new type of files (with
    corresponding suffix) as recognized by Frama-C through [func].
    @plugin development guide
*)

type code_transformation_category
(** type of registered code transformations
    @since Neon-20140301
*)

val register_code_transformation_category:
  string -> code_transformation_category
(** Adds a new category of code transformation *)

val add_code_transformation_before_cleanup:
  ?deps:(module Parameter_sig.S) list ->
  ?before:code_transformation_category list ->
  ?after:code_transformation_category list ->
  code_transformation_category -> (Cil_types.file -> unit) -> unit
(** [add_code_transformation_before_cleanup name hook]
    adds an hook in the corresponding category
    that will be called during the normalization of a linked
    file, before clean up and removal of temps and unused declarations.
    If this transformation involves changing statements of a function [f],
    [f] must be flagged with {!File.must_recompute_cfg}.
    The optional [before] (resp [after]) categories indicates that current
    transformation must be executed before (resp after)
    the corresponding ones, if they exist. In case of dependencies cycle,
    an arbitrary order will be chosen for the transformations involved in
    the cycle.
    The optional [deps] argument gives the list of options whose change
    (e.g. after a [-then]) will trigger the transformation over the already
    computed AST. If several transformations are triggered by the same
    option, their relative order is preserved.
    Note that it is the responsibility of the hook to use
    {!Ast.mark_as_changed} or {!Ast.mark_as_grown} whenever it is the case.

    At this level, globals and ACSL annotations have not been registered.

    @since Neon-20140301
    @plugin development guide *)

val add_code_transformation_after_cleanup:
  ?deps:(module Parameter_sig.S) list ->
  ?before:code_transformation_category list ->
  ?after:code_transformation_category list ->
  code_transformation_category -> (Cil_types.file -> unit) -> unit
(** Same as above, but the hook is applied after clean up.
    At this level, globals and ACSL annotations have been registered. If
    the hook adds some new globals or annotations, it must take care of
    adding them in the appropriate tables.
    @since Neon-20140301
    @plugin development guide *)

val must_recompute_cfg: Cil_types.fundec -> unit
(** [must_recompute_cfg f] must be called by code transformation hooks
    when they modify statements in function [f]. This will trigger a
    recomputation of the cfg of [f] after the transformation.
    @since Neon-20140301
    @plugin development guide *)

val get_suffixes: unit -> string list
(** @return the list of accepted suffixes of input source files
    @since Boron-20100401 *)

val get_name: t -> string
(** File name. *)

val get_preprocessor_command: unit -> string * cpp_opt_kind
(** Return the preprocessor command to use. *)


val pre_register: t -> unit
(** Register some file as source file before command-line files.
    Useful for additional libc source files. *)

val pre_register_dynamic: (unit -> bool) -> (unit -> t) -> unit
(** [pre_register_dynamic cond get_file]
    Like [pre_register], however the [t] file is retrieved when [cond]
    returns [true]. For instance, it allows to have a [t] file with a
    different pre-processing line or path depending on the current
    options.
    @param cond: The given file is registered only if [cond] returns
    [true]. [cond] is evaluated:
    - after each Configuring stage (see [Cmdline.stage])
    - during each project creation (once for [Project.create] and
      twice for [Project.create_by_copy]) *)

val register_preprocessor_extra_args: ?gnu:bool -> ?pre:bool -> string
  -> unit
(** [register_preprocessor_extra_args ?gnu ?pre args] registers the given
    [args] as an additional extra argument in the preprocessor command
    line, like the option -cpp-extra-args.
    Preprocessor arguments given by this functions persists throught projects
    (otherwise use [register_preprocessor_extra_args_dynamic]).
    @param gnu: if set to [true], [args] is added only on files
    tagged [Gnu] (see [cpp_opt_kind]). Default: [false]
    @param pre: if set to [true], [args] are added just before the arguments
    given with -cpp-extra-args. After otherwise. Default: [true]. *)

val register_preprocessor_extra_args_dynamic: ?gnu:bool -> ?pre:bool
  -> (unit -> string option) -> unit
(** [register_preprocessor_extra_args_dynamic ?gnu ?pre fn]
    Like [register_preprocessor_extra_args], however the argument can be made
    dymanically before calling the preprocessor for each [NeedCPP] file.
    @param fn can return [None] in order to not add anything. *)

val get_all: unit -> t list
(** Return the list of toplevel files. *)

val get_pre_register: unit -> t list
(** Return the list of source file registered by [pre_register]. *)

val from_filename: ?cpp:string -> string -> t
(** Build a file from its name. The optional argument is the preprocessor
    command. Default is [!get_preprocessor_command ()]. *)

(* ************************************************************************* *)
(** {2 Initializers} *)
(* ************************************************************************* *)

type parse_result_status = Success | Failure of exn

(** A parsing result, given to the [exec_on_result_parse_file] callback *)
type parse_result = private {
  status: parse_result_status;
  (** The returned status *)

  std_output: string option;
  (** The output of the pre-processing command (stdout and stderr) *)

  cpp_command: string option;
  (** The command line used for the pre-processing *)
}

val exec_on_result_parse_file:
  (t -> parse_result -> unit) option ref
(** When set, the given function will be called when a file
    has been parsed (successfully or not).
    The first argument is the parsed file.
    The second argument is the parsing result of the pre-processing command *)

val prepare_from_c_files: unit -> unit
(** Initialize the AST of the current project according to the current
    filename list.
    @raise File_types.Bad_Initialization if called more than once. *)

val init_from_c_files: t list -> unit
(** Initialize the cil file representation of the current project.
    Should be called at most once per project.
    @raise File_types.Bad_Initialization if called more than once.
    @plugin development guide *)

val init_project_from_cil_file: Project.t -> Cil_types.file -> unit
(** Initialize the cil file representation with the given file for the
    given project from the current one.
    Should be called at most once per project.
    @raise File_types.Bad_Initialization if called more than once.
    @plugin development guide *)

val init_project_from_visitor:
  ?reorder:bool -> Project.t -> Visitor.frama_c_visitor -> unit
(** [init_project_from_visitor prj vis] initialize the cil file
    representation of [prj]. [prj] must be essentially empty: it can have
    some options set, but not an existing cil file; [proj] is filled using
    [vis], which must be a copy visitor that puts its results in [prj].
    if [reorder] is [true] (default is [false]) the new AST in [prj]
    will be reordered.
    @since Oxygen-20120901
    @modify Fluorine-20130401 added reorder optional argument
    @plugin development guide
*)

val create_project_from_visitor:
  ?reorder:bool -> ?last:bool ->
  string ->
  (Project.t -> Visitor.frama_c_visitor) ->
  Project.t
(** Return a new project with a new cil file representation by visiting the
    file of the current project. If [reorder] is [true], the globals in the
    AST of the new project are reordered (default is [false]). If [last] is
    [true] (by default), remember than the returned project is the last
    created one.
    The visitor is responsible to avoid sharing between old file and new
    file (i.e. it should use {!Cil.copy_visit} at some point).
    @raise File_types.Bad_Initialization if called more than once.
    @since Beryllium-20090601-beta1
    @modify Fluorine-20130401 added [reorder] optional argument
    @modify Sodium-20150201 added [last] optional argument
    @plugin development guide *)

val create_rebuilt_project_from_visitor:
  ?reorder:bool -> ?last:bool -> ?preprocess:bool ->
  string -> (Project.t -> Visitor.frama_c_visitor) -> Project.t
(** Like {!create_project_from_visitor}, but the new generated cil file is
    generated into a temp .i or .c file according to [preprocess], then re-built
    by Frama-C in the returned project. For instance, use this function if the
    new cil file contains a constructor {!GText} as global.

    Note that the generation of a preprocessed C file may fail in some cases
    (e.g. if it includes headers already included). Thus the generated file is
    NOT preprocessed by default.

    @raise File_types.Bad_Initialization if called more than once.
    @since Nitrogen-20111001
    @modify Fluorine-20130401 added reorder optional argument
*)

val init_from_cmdline: unit -> unit
(** Initialize the cil file representation with the file given on the
    command line.
    Should be called at most once per project.
    @raise File_types.Bad_Initialization if called more than once.
    @plugin development guide *)

val reorder_ast: unit -> unit
(** reorder globals so that all uses of an identifier are preceded by its
    declaration. This may introduce new declarations in the AST.
    @since Oxygen-20120901
*)

val reorder_custom_ast: Cil_types.file -> unit
(** @since Neon-20140301 *)

(* ************************************************************************* *)
(** {2 Pretty printing} *)
(* ************************************************************************* *)

val pretty_ast : ?prj:Project.t -> ?fmt:Format.formatter -> unit -> unit
(** Print the project CIL file on the given Formatter.
    The default project is the current one.
    The default formatter is [Kernel.CodeOutput.get_fmt ()].
    @raise File_types.Bad_Initialization if the file is not initialized. *)

(*
Local Variables:
compile-command: "make -C ../../.."
End:
*)
