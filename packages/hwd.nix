{ wrhiteShellScriptBin, ... }:
writeShellScriptBin "hwd" ''
  nix why-depends $(home-manager generations | head -n1 | cut -d' ' -f7) $@
''
