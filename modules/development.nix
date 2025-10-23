{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{

  options.enableDevelopment = mkEnableOption "";

  config = mkIf config.enableDevelopment {
    home.packages = with pkgs; [
      gemini-cli
      nil # nix language server
      nixd # nix language server
      nixfmt-rfc-style

      gitu

      jetbrains-toolbox
    ];

    programs.awscli.enable = true;

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code;
    };

    programs.lazygit.enable = true;

    programs.doom-emacs = {
      enable = true;
      doomDir = ../share/doom.d;
    };

    home.shellAliases.magit = "emacs -nw -f magit";
  };
}
