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
      code
      ccstatusline
      mcp-cmd
      notebooklm-mcp
      opencode
      nodejs # needed to handle skills in opencode/codex

      claude-code-jailed
      opencode-jailed
      gemini-cli-bin-jailed
      
      uv

      devcontainer-standalone
      gitu
      gemini-podman
      jetbrains-toolbox
      jules
      hurl
      nil # nix language server
      nixd # nix language server
      nixfmt
      serena
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
      # TODO: configure sandbox
      # GEMINI_SANDBOX=podman GEMINI_SANDBOX_IMAGE=us-docker.pkg.dev/gemini-code-dev/gemini-cli/sandbox:0.22.1 SANDBOX_FLAGS="--security-opt label=disable" gemini --sandbox
    };
    
  };
}
