(**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "hack" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *)

(*****************************************************************************)
(* This module defines the data structured used to describe the content of
 * a file.
 * The parser constructs FileInfo.t structs, that contain names and positions
 * plus some extra info required for the build.
 * After the names have been checked (Naming.make_env), we "simplify" the
 * struct and only keep the names defined in the files we know about.
 *)
(*****************************************************************************)

open Utils

(*****************************************************************************)
(* The record produced by the parsing phase. *)
(*****************************************************************************)

type id = Pos.t * string

type t = {
  funs : id list;
  classes : id list;
  types : id list;
  consts : id list;
  comments : (Pos.t * string) list;
  consider_names_just_for_autoload: bool;
}

(*****************************************************************************)
(* The simplified record used after parsing. *)
(*****************************************************************************)

type names = {
  n_funs    : SSet.t;
  n_classes : SSet.t;
  n_types   : SSet.t;
  n_consts  : SSet.t;
}

type fast = names SMap.t

let empty_names = {
  n_funs    = SSet.empty;
  n_classes = SSet.empty;
  n_types   = SSet.empty;
  n_consts  = SSet.empty;
}

(*****************************************************************************)
(* Functions simplifying the file information. *)
(*****************************************************************************)
    
let name_set_of_idl idl =
  List.fold_left (fun acc (_, x) -> SSet.add x acc) SSet.empty idl

let simplify info =
  let {funs; classes; types; consts; comments = _;
       consider_names_just_for_autoload = _ } = info in
  let n_funs    = name_set_of_idl funs in
  let n_classes = name_set_of_idl classes in
  let n_types   = name_set_of_idl types in
  let n_consts  = name_set_of_idl consts in
  {n_funs; n_classes; n_types; n_consts}

let merge_names t_names1 t_names2 =
  let {n_funs; n_classes; n_types; n_consts} = t_names1 in
  {
   n_funs    = SSet.union n_funs t_names2.n_funs;
   n_classes = SSet.union n_classes t_names2.n_classes;
   n_types   = SSet.union n_types t_names2.n_types;
   n_consts  = SSet.union n_consts t_names2.n_consts;
 }

let simplify_fast fast =
  SMap.map simplify fast
