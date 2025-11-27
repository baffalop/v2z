module Keymap : sig
  type t

  val to_json : t -> Yojson.Safe.t
  val from_json : Yojson.Safe.t -> (t, string) result

  val from_file : string -> t
end

module Print : sig
  val keymap : Keymap.t -> string
end
