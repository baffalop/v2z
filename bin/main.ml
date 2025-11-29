open Vim2zed

let () =
  match Array.to_list Sys.argv with
  | [_; filename] ->
    (* let input_keymap = Zed.Keymap.from_file "data/default-keymap.json" in *)
    let vim_mappings = Vim.Parse.from_file filename in
    let zed = Vim.ToZed.keymap vim_mappings in
    let output_json = Zed.Keymap.to_json zed.keymap in
    let () = print_endline @@ Yojson.Safe.pretty_to_string output_json in
    if zed.errors = [] then () else
      let () = prerr_endline "Warning:" in
      List.iter (fun error -> Printf.eprintf "%s\n" error) zed.errors

  | _ ->
    Printf.eprintf "Usage: %s <vim_file>\n" Sys.argv.(0);
    exit 1
