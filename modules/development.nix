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
      # llm tools
      ccstatusline
      chrome-devtools-mcp
      mcp-cmd
      notebooklm-mcp
      jules
      
      # ad-hoc mcp servers need these
      nodejs
      uv
      
      opencode

      claude-code-jailed
      opencode-jailed
      gemini-cli-bin-jailed
      
      devcontainer-standalone
      gitu
      jetbrains-toolbox
      hurl
      nil # nix language server
      nixd # nix language server
      nixfmt
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

    programs.pi = {
      enable = true;
      extensions = with pkgs.piExtensions; [
        tools
        plan-mode
        # sandbox
      ];
      skills = with pkgs.piSkills; [
        # conductor-setup
        # conductor-implement
        # conductor-new-track
        # conductor-status
        # conductor-revert
      ];
    };
    
  };
}
