{ pkgs, nodejs ? pkgs.nodejs, ... }:

let
  composition = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (pkgs) system;
  };
  clipboard-linux = composition."@mariozechner/clipboard-linux-x64-gnu";
in
composition."@mariozechner/pi-coding-agent".overrideAttrs (oldAttrs: {
  meta = (oldAttrs.meta or { }) // {
    mainProgram = "pi";
  };

  postInstall = (oldAttrs.postInstall or "") + ''
    # Manually link optional dependency that node2nix missed
    mkdir -p $out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules/@mariozechner
    ln -s ${clipboard-linux}/lib/node_modules/@mariozechner/clipboard-linux-x64-gnu $out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules/@mariozechner/clipboard-linux-x64-gnu
  '';
})