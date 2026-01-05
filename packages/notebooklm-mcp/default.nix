{ pkgs, nodejs ? pkgs.nodejs, ... }:

let
  composition = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (pkgs) system;
  };
in
composition.notebooklm-mcp
