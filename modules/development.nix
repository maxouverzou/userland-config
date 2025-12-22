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
      amp-cli

      gitu
      jetbrains-toolbox
      jules
      nil # nix language server
      nixd # nix language server
      nixfmt-rfc-style
    ];

    programs.awscli.enable = true;

    programs.claude-code.enable = true;

    programs.codex.enable = true;

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

    programs.gemini-cli = {
      enable = true;
      package = pkgs.gemini-cli-bin;
    };
    
  };
}
