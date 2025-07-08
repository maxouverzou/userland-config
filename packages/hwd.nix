{
  writeShellApplication,
  nix,
  home-manager,
  ...
}:
writeShellApplication {
  name = "hwd";
  runtimeInputs = [
    nix
    home-manager
  ];

  text = ''
    nix why-depends "$(home-manager generations | head -n1 | cut -d' ' -f7)" "$@"
  '';
}
