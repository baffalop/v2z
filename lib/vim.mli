type mode =
  | All
  | Normal
  | Visual
  | Select
  | Visual_x
  | Insert
  | Operator
  | Command
  | Lang
  | Terminal

type map_type = Map | Noremap

type keystroke =
  | Char of char
  | Leader
  | Return
  | Escape
  | Space
  | Tab
  | Backspace
  | Delete
  | Control of char
  | Alt of char
  | Shift of char
  | F of int
  | Arrow of [`Up | `Down | `Left | `Right]
  | Plug of string
  | Special of string

type mapping = {
  mode: mode;
  map_type: map_type;
  trigger: keystroke list;
  target: keystroke list;
}

module Parse : sig
  val parse_line : string -> mapping option
  val from_file : string -> mapping list
end

module ToZed : sig
  type mapping_result = {
    keymap: Zed.Keymap.t;
    errors: string list;
  }

  val keymap : mapping list -> mapping_result
end

module Print : sig
  val mode : mode -> string
  val map_type : map_type -> string
  val keystrokes : keystroke list -> string
  val mapping_short : mapping -> string
  val mapping_full : mapping -> string
  val pretty : mapping list -> string
end
