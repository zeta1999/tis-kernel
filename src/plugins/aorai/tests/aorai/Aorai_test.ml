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

(* Small script to test that the code generated by aorai can be parsed again
 * by frama-c.
*)

open Kernel

module StdString = String

include Plugin.Register
    (struct
      let name = "aorai testing module"
      let shortname = "aorai-test"
      let help = "utility script for aorai regtests"
    end)

module TestNumber =
  Zero
    (struct
      let option_name = "-aorai-test-number"
      let help = "test number when multiple tests are run over the same file"
      let arg_name = "n"
    end)

module InternalWpShare =
  Empty_string(
  struct
    let option_name = "-aorai-test-wp-share"
    let help = "use custom wp share dir (when in internal plugin mode)"
    let arg_name = "dir"
  end)

let tmpfile = ref (Filename.temp_file "aorai_test" ".i")

let tmpfile_set = ref false

let ok = ref false

let () =
  at_exit (fun () ->
      if Debug.get () >= 1 || not !ok then
        result "Keeping temp file %s" !tmpfile
      else
        try Sys.remove !tmpfile with Sys_error _ -> ())

let set_tmpfile _ l =
  if not !tmpfile_set then
    begin
      let name = List.hd l in
      let name = Filename.basename name in
      let name = Filename.chop_extension name in
      tmpfile := (Filename.get_temp_dir_name()) ^ "/aorai_" ^ name ^
                 (string_of_int (TestNumber.get())) ^ ".i";
      tmpfile_set := true
    end

let () = Kernel.Files.add_set_hook set_tmpfile

let is_suffix suf str =
  let lsuf = StdString.length suf in
  let lstr = StdString.length str in
  if lstr <= lsuf then false
  else
    let estr = StdString.sub str (lstr - lsuf) lsuf in
    estr = suf

let extend () =
  let myrun =
    let run = !Db.Toplevel.run in
    fun f ->
      let my_project = Project.create "Reparsing" in
      let wp_compute_kf =
        Dynamic.get ~plugin:"Wp" "wp_compute_kf"
          Datatype.(
            func3 (option Kernel_function.ty) (list string) (list string) unit)
      in
      let check_auto_func kf =
        let name = Kernel_function.get_name kf in
        if Kernel_function.is_definition kf &&
           (is_suffix "_pre_func" name || is_suffix "_post_func" name)
        then
          wp_compute_kf (Some kf) [] []
      in
      run f;
      let chan = open_out !tmpfile in
      let fmt = Format.formatter_of_out_channel chan in
      File.pretty_ast ~prj:(Project.from_unique_name "aorai") ~fmt ();
      close_out chan;
      let selection = State_selection.singleton InternalWpShare.self in
      Project.copy ~selection my_project;
      Project.set_current my_project;
      Files.append_after [ !tmpfile ];
      Constfold.off ();
      Ast.compute();
      let wp_share = InternalWpShare.get() in
      if wp_share <> "" then
        Dynamic.Parameter.String.set "-wp-share" wp_share;
      Dynamic.Parameter.Int.set "-wp-verbose" 0;
      Globals.Functions.iter check_auto_func;
      File.pretty_ast ();
      ok:=true (* no error, we can erase the file *)

  in
  Db.Toplevel.run := myrun

let () = extend ()
