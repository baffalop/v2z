open Yojson.Safe

(* Type definitions for Zed keymap structure *)

(* Represents an action that can be bound to a key *)
type action =
  | SimpleAction of string
  | ActionWithParams of string * (string * Yojson.Safe.t) list

(* Represents a key binding entry *)
type binding = {
  key: string;
  action: action;
}

(* Represents a context block with its condition and bindings *)
type context_block = {
  context: string;
  bindings: binding list;
  use_key_equivalents: bool option;
}

(* The complete keymap structure *)
type keymap = context_block list

(* Helper function to parse an action from JSON *)
let parse_action json =
  match json with
  | `String action_name -> SimpleAction action_name
  | `List [`String action_name; `Assoc params] ->
      let parsed_params = List.map (fun (k, v) -> (k, v)) params in
      ActionWithParams (action_name, parsed_params)
  | _ -> failwith "Invalid action format"

(* Parse a single binding from a key-value pair *)
let parse_binding key json =
  { key; action = parse_action json }

(* Parse bindings object into a list of bindings *)
let parse_bindings json =
  match json with
  | `Assoc bindings_list ->
      List.map (fun (key, action_json) -> parse_binding key action_json) bindings_list
  | _ -> failwith "Invalid bindings format"

(* Parse a single context block *)
let parse_context_block json =
  match json with
  | `Assoc fields ->
      let context =
        match List.assoc_opt "context" fields with
        | Some (`String ctx) -> ctx
        | _ -> failwith "Missing or invalid context field"
      in
      let bindings =
        match List.assoc_opt "bindings" fields with
        | Some bindings_json -> parse_bindings bindings_json
        | None -> []
      in
      let use_key_equivalents =
        match List.assoc_opt "use_key_equivalents" fields with
        | Some (`Bool b) -> Some b
        | None -> None
        | _ -> failwith "Invalid use_key_equivalents field"
      in
      { context; bindings; use_key_equivalents }
  | _ -> failwith "Invalid context block format"

(* Parse the entire keymap from JSON *)
let parse_keymap json =
  match json with
  | `List context_blocks ->
      List.map parse_context_block context_blocks
  | _ -> failwith "Invalid keymap format: expected array of context blocks"

(* Load keymap from file *)
let load_keymap_from_file filename =
  let json = from_file filename in
  parse_keymap json

(* Pretty printing functions *)

let string_of_action = function
  | SimpleAction name -> name
  | ActionWithParams (name, params) ->
      let param_strings = List.map (fun (k, v) ->
        Printf.sprintf "%s: %s" k (to_string v)) params in
      Printf.sprintf "%s(%s)" name (String.concat ", " param_strings)

let string_of_binding binding =
  Printf.sprintf "%s -> %s" binding.key (string_of_action binding.action)

let string_of_context_block block =
  let bindings_str = String.concat "\n  "
    (List.map string_of_binding block.bindings) in
  let use_key_equiv_str = match block.use_key_equivalents with
    | Some true -> "\n  use_key_equivalents: true"
    | Some false -> "\n  use_key_equivalents: false"
    | None -> ""
  in
  Printf.sprintf "Context: %s%s\nBindings:\n  %s"
    block.context use_key_equiv_str bindings_str

let string_of_keymap keymap =
  String.concat "\n\n" (List.map string_of_context_block keymap)

(* Utility functions for working with keymaps *)

(* Find all bindings for a specific context *)
let find_context_bindings keymap context_name =
  let matching_blocks = List.filter (fun block ->
    String.equal block.context context_name) keymap in
  List.concat_map (fun block -> block.bindings) matching_blocks

(* Find all contexts that bind a specific key *)
let find_key_contexts keymap key =
  List.filter_map (fun block ->
    let has_key = List.exists (fun binding ->
      String.equal binding.key key) block.bindings in
    if has_key then Some block.context else None
  ) keymap

(* Get all unique keys used across all contexts *)
let get_all_keys keymap =
  let all_bindings = List.concat_map (fun block -> block.bindings) keymap in
  let keys = List.map (fun binding -> binding.key) all_bindings in
  List.sort_uniq String.compare keys

(* Get all unique actions used across all contexts *)
let get_all_actions keymap =
  let all_bindings = List.concat_map (fun block -> block.bindings) keymap in
  let actions = List.map (fun binding -> string_of_action binding.action) all_bindings in
  List.sort_uniq String.compare actions

(* Get all unique contexts *)
let get_all_contexts keymap =
  List.map (fun block -> block.context) keymap
  |> List.sort_uniq String.compare
