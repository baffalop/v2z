type cmd =
  | Cmd of string
  | CmdArgs of string * Yojson.Safe.t
  | Null

type binding = {
  key: string;
  cmd: cmd;
}

type context_block = {
  context: string;
  bindings: binding list
}

module Keymap : sig
  type t

  val to_json : t -> Yojson.Safe.t
  val from_json : Yojson.Safe.t -> (t, string) result

  val from_file : string -> t

  (** Constructing a keymap *)

  val empty : t
  val add_binding_in_context: ctx:string -> key:string -> cmd:cmd -> t -> t
end

module Print : sig
  val keymap : Keymap.t -> string
end
