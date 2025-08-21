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
      nil # nix language server
      nixd # nix language server
      nixfmt-rfc-style
    ];

    programs.awscli.enable = true;

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code-stable;
    };

    programs.lazygit.enable = true;
  };
}
