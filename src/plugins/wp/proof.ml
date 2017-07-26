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

(* -------------------------------------------------------------------------- *)
(* --- Proof Script Database                                              --- *)
(* -------------------------------------------------------------------------- *)

let scriptbase : (string, string list * string * string) Hashtbl.t = Hashtbl.create 81
(* [ goal name -> sorted hints , script , closing ] *)
let scriptfile = ref None (* current file script name *)
let needback   = ref false (* file script need backup before modification *)
let needsave   = ref false (* file script need to be saved *)
let needwarn   = ref false (* user should be prompted for chosen scriptfile *)

let clear () =
  begin
    Hashtbl.clear scriptbase ;
    scriptfile := None ;
    needback := false ;
    needsave := false ;
  end

let sanitize hint =
  try
    let n = String.length hint in
    if n <= 0 then raise Exit ;
    for i = 0 to n - 1 do
      match hint.[i] with
      | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '-' | '*' -> ()
      | _ -> raise Exit
    done ; true
  with Exit -> false

let register_script goal hints proof closing =
  let hints = List.sort String.compare (List.filter sanitize hints) in
  Hashtbl.replace scriptbase goal (hints,proof,closing)

let delete_script goal =
  Hashtbl.remove scriptbase goal

(* -------------------------------------------------------------------------- *)
(* --- Proof Scripts Parsers                                              --- *)
(* -------------------------------------------------------------------------- *)

open Script

let is_empty script =
  try
    for i=0 to String.length script - 1 do
      match script.[i] with '\n' | ' ' | '\t' -> () | _ -> raise Exit
    done ; true
  with Exit -> false

let parse_coqproof file =
  let input = Script.open_file file in
  try
    let rec fetch_proof input =
      match token input with
      | Proof(p,c) -> Some(p,c)
      | Eof -> None
      | _ -> skip input ; fetch_proof input
    in
    let proof = fetch_proof input in
    Script.close input ; proof
  with e ->
    Script.close input ;
    raise e

let collect_scripts input =
  while key input "Goal" do
    let g = ident input in
    eat input "." ;
    let xs =
      if key input "Hint" then
        let xs = idents input in
        eat input "." ; xs
      else []
    in
    let proof,qed =
      match token input with
      | Proof(p,c) -> skip input ; p,c
      | _ -> error input "Missing proof"
    in
    register_script g xs proof qed
  done ;
  if token input <> Eof
  then error input "Unexpected script declaration"

let parse_scripts file =
  if Sys.file_exists file then
    begin
      let input = Script.open_file file in
      try
        collect_scripts input ;
        Script.close input ;
      with e ->
        Script.close input ;
        raise e
    end

let dump_scripts file =
  let out = open_out file in
  let fmt = Format.formatter_of_out_channel out in
  try
    Format.fprintf fmt "@\n" ;
    let goals = Hashtbl.fold (fun goal _ gs -> goal::gs) scriptbase [] in
    List.iter
      (fun goal ->
         let (hints,proof,qed) = Hashtbl.find scriptbase goal in
         Format.fprintf fmt "Goal %s.@\n" goal ;
         (match hints with
          | [] -> ()
          | k::ks ->
            Format.fprintf fmt "Hint %s" k ;
            List.iter (fun k -> Format.fprintf fmt ",%s" k) ks ;
            Format.fprintf fmt ".@\n");
         Format.fprintf fmt "Proof.@\n%s@\n%s@\n@." proof qed
      ) (List.sort String.compare goals) ;
    Format.pp_print_newline fmt () ;
    close_out out ;
  with e ->
    Format.pp_print_newline fmt () ;
    close_out out ;
    raise e

(* -------------------------------------------------------------------------- *)
(* --- Scripts Management                                                 --- *)
(* -------------------------------------------------------------------------- *)

let rec choose k =
  let file = Printf.sprintf "wp%d.script" k in
  if Sys.file_exists file then choose (succ k) else file

let savescripts () =
  if !needsave then
    match !scriptfile with
    | None -> ()
    | Some file ->
      if Wp_parameters.UpdateScript.get () then
        try
          if !needback then
            ( Command.copy file (file ^ ".back") ; needback := false ) ;
          if !needwarn then
            ( needwarn := false ;
              Wp_parameters.warning ~current:false
                "No script file specified.@\n\
                 Your proofs are saved in '%s'@\n\
                 Use -wp-script '%s' to re-run them."
                file file ;
            ) ;
          dump_scripts file ;
          needsave := false ;
        with e ->
          Wp_parameters.abort
            "Error when dumping script file '%s':@\n%s" file
            (Printexc.to_string e)
      else
        Wp_parameters.warning ~once:true ~current:false
          "Script base modified : modification will not be saved"

let loadscripts () =
  let user = Wp_parameters.Script.get () in
  if !scriptfile <> Some user then
    begin
      savescripts () ;
      begin
        try parse_scripts user ;
        with e ->
          Wp_parameters.error
            "Error in script file '%s':@\n%s" user
            (Printexc.to_string e)
      end ;
      if Wp_parameters.UpdateScript.get () then
        if user = "" then
          (* update new file *)
          begin
            let ftmp = choose 0 in
            Wp_parameters.Script.set ftmp ;
            scriptfile := Some ftmp ;
            needwarn := true ;
            needback := false ;
          end
        else
          (* update user's file *)
          begin
            scriptfile := Some user ;
            needback := Sys.file_exists user ;
          end
      else
        (* do not update *)
        begin
          scriptfile := Some user ;
          needback := false ;
        end
    end

let find_script_for_goal goal =
  loadscripts () ;
  try
    let _,proof,qed = Hashtbl.find scriptbase goal in
    Some(proof,qed)
  with Not_found -> None

let update_hints_for_goal goal hints =
  try
    let old_hints,script,qed = Hashtbl.find scriptbase goal in
    let new_hints = List.sort String.compare hints in
    if Pervasives.compare new_hints old_hints <> 0 then
      begin
        Hashtbl.replace scriptbase goal (new_hints,script,qed) ;
        needsave := true ;
      end
  with Not_found -> ()


let rec matches n xs ys =
  match xs , ys with
  | x::rxs , y::rys ->
    let c = String.compare x y in
    if c < 0 then matches n rxs ys else
    if c > 0 then matches n xs rys else
      matches (succ n) rxs rys
  | _ -> n

let rec filter xs ys =
  match xs , ys with
  | [] , _ -> ys
  | _::_ , [] -> raise Not_found
  | x::rxs , y::rys ->
    let c = String.compare x y in
    if c < 0 then raise Not_found else
    if c > 0 then y :: filter xs rys else
      filter rxs rys

let most_suitable (n,_,_,_) (n',_,_,_) = n'-n

let find_script_with_hints required hints =
  loadscripts () ;
  let required = List.sort String.compare required in
  let hints = List.sort String.compare hints in
  List.sort most_suitable
    begin
      Hashtbl.fold
        (fun g (xs,proof,qed) scripts ->
           try
             let n = matches 0 hints (filter required xs) in
             (n,g,proof,qed)::scripts
           with Not_found -> scripts)
        scriptbase []
    end

let add_script goal hints proof =
  needsave := true ; register_script goal hints proof

(* -------------------------------------------------------------------------- *)
(* --- Prover API                                                         --- *)
(* -------------------------------------------------------------------------- *)

let script_for ~pid ~gid =
  match find_script_for_goal gid with
  | None -> None
  | (Some _) as script ->
    let required,hints = WpPropId.prop_id_keys pid in
    let all = List.merge String.compare required hints in
    update_hints_for_goal gid all ;
    script

let rec head n = function [] -> []
                        | x::xs -> if n > 0 then x :: head (pred n) xs else []

let hints_for ~pid =
  let default = match Wp_parameters.CoqTactic.get () with
    | "none" -> []
    | tactic -> ["Default tactic",Printf.sprintf "  %s.\n" tactic,"Qed."]
  in
  if Wp_parameters.TryHints.get () then
    let nhints = Wp_parameters.Hints.get () in
    if nhints > 0 then
      let required,hints = WpPropId.prop_id_keys pid in
      let scripts = find_script_with_hints required hints in
      default @ List.map (fun (_,_,s,q) -> "Hint",s,q) (head nhints scripts)
    else default
  else default

let script_for_ide ~pid ~gid =
  match find_script_for_goal gid with
  | Some script -> script
  | None ->
    let required,hints = WpPropId.prop_id_keys pid in
    let hints = find_script_with_hints required hints in
    let script =
      if hints = [] then
        begin
          match Wp_parameters.CoqTactic.get () with
          | "none" -> ""
          | tactic -> Pretty_utils.sfprintf "(* %s. *)\n" tactic
        end
      else
        begin
          let nhints = Wp_parameters.Hints.get () in
          Pretty_utils.sfprintf "%t"
            (fun fmt ->
               List.iter
                 (fun (_,g,script,_) ->
                    Format.fprintf fmt
                      "(*@ --------------------------------------\n  \
                       @ From '%s': \n%s*)\n%!" g script
                 ) (head nhints hints))
        end
    in script , "Qed."
