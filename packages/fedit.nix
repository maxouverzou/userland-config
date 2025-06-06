{
  writeShellApplication,
  fd,
  fzf,
  bat,
  ...
}:
writeShellApplication {
  name = "fedit";
  runtimeInputs = [
    fd
    fzf
    bat
  ];
  text = ''
    directory="''${1:-.}"
    fd . --type f "$directory" \
      | fzf --preview "bat --color=always {}" --multi --bind "enter:become(\\$EDITOR {+})"
  '';
}
