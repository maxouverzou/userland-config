{
  writeShellApplication,
  fzf,
  git,
  ...
}:
writeShellApplication {
  name = "frbi";
  runtimeInputs = [
    fzf
    git
  ];
  text = ''
    git rebase -i "$(git log --pretty=oneline --color=always \
      | fzf --ansi --header "Pick rebase starting point" \
      | cut -d ' ' -f1)^"
  '';
}
