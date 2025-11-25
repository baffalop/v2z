# Vim-2-Zed

A script for translating Vim mappings (vimrc) to Zed keymap format.

## Usage

```bash
# WIP: output not implemented yet
v2z input.vim output.json
```

This will parse your Vim configuration file and generate a Zed keymap file that you can use in your Zed editor settings.

## Build from Source

### Prerequisites

- OCaml (≥ 4.14) + toolchain:
  - Opam package manager
  - Dune build system
  - See https://ocaml.org/docs/install.html for a setup guide

### Building

```bash
# Install dependencies
opam install . --deps-only

# Build the project
dune build

# Install locally (optional)
dune install
```

The executable will be available as `_build/default/bin/main.exe` or installed as `v2z` if you ran `dune install`.
