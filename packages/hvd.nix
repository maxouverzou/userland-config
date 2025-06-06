{
  writeShellApplication,
  nvd,
  home-manager,
  fzf,
  ...
}:
writeShellApplication {
  name = "hvd";
  runtimeInputs = [
    nvd
    home-manager
    fzf
  ];
  text = ''
    _diff ()
    {

      local HEAD
      local REVISION
      HEAD=$(home-manager generations | head -n1 | cut -d' ' -f7)
      REVISION=$(cut -d' ' -f7 <<< "$1")

      nvd --color=always diff "$REVISION" "$HEAD"
    }

    export -f _diff

    home-manager generations \
      | tail -n+2 \
      | fzf --preview "_diff {}" \
      | cat
  '';
}
