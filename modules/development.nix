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
      gemini-cli-bin
      gitu
      jetbrains-toolbox
      jules
      nil # nix language server
      nixd # nix language server
      nixfmt-rfc-style


    ];

    programs.awscli.enable = true;

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code;
    };

    programs.lazygit.enable = true;

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "decorations";
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };
    
    programs.doom-emacs = {
      enable = true;
      doomDir = ../share/doom.d;
    };

    home.shellAliases.magit = "emacs -nw -f magit";
  };
}
