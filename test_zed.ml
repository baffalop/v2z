open Vim2zed.Zed

(* Helper function to take first n elements from a list *)
let rec take n lst =
  match n, lst with
  | 0, _ | _, [] -> []
  | n, x :: xs when n > 0 -> x :: take (n - 1) xs
  | _ -> []

let () =
  try
    (* Load the keymap from the JSON file *)
    let keymap = load_keymap_from_file "data/default-keymap.json" in

    (* Print basic statistics *)
    Printf.printf "=== Zed Keymap Analysis ===\n\n";
    Printf.printf "Total context blocks: %d\n" (List.length keymap);

    let all_contexts = get_all_contexts keymap in
    Printf.printf "Total unique contexts: %d\n" (List.length all_contexts);

    let all_keys = get_all_keys keymap in
    Printf.printf "Total unique keys: %d\n" (List.length all_keys);

    let all_actions = get_all_actions keymap in
    Printf.printf "Total unique actions: %d\n" (List.length all_actions);

    (* Print all contexts *)
    Printf.printf "\n=== All Contexts ===\n";
    List.iteri (fun i context ->
      Printf.printf "%d. %s\n" (i + 1) context
    ) all_contexts;

    (* Show the first context block in detail *)
    match keymap with
    | first_block :: _ ->
        Printf.printf "\n=== First Context Block (Sample) ===\n";
        Printf.printf "%s\n" (string_of_context_block first_block);

        (* Show first 10 bindings *)
        Printf.printf "\n=== First 10 Bindings ===\n";
        let sample_bindings = take 10 first_block.bindings in
        List.iteri (fun i binding ->
          Printf.printf "%d. %s\n" (i + 1) (string_of_binding binding)
        ) sample_bindings
    | [] ->
        Printf.printf "No context blocks found\n";

    (* Find vim control context specifically *)
    Printf.printf "\n=== VimControl Context Analysis ===\n";
    let vim_control_bindings = find_context_bindings keymap "VimControl && !menu" in
    Printf.printf "VimControl bindings count: %d\n" (List.length vim_control_bindings);

    (* Show some common keys and their contexts *)
    Printf.printf "\n=== Key Usage Analysis ===\n";
    let common_keys = ["h"; "j"; "k"; "l"; "i"; "a"; "escape"; ":"; "ctrl-c"] in
    List.iter (fun key ->
      let contexts = find_key_contexts keymap key in
      Printf.printf "Key '%s' used in %d contexts: %s\n"
        key (List.length contexts) (String.concat ", " contexts)
    ) common_keys;

  with
  | Sys_error msg ->
      Printf.eprintf "File error: %s\n" msg;
      exit 1
  | Failure msg ->
      Printf.eprintf "Parse error: %s\n" msg;
      exit 1
  | exn ->
      Printf.eprintf "Unexpected error: %s\n" (Printexc.to_string exn);
      exit 1
