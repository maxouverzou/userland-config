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
      jules
      skills
      
      # ad-hoc mcp servers need these
      nodejs
      uv
      
      opencode

      claude-code-jailed
      opencode-jailed
      gemini-cli-bin-jailed
      (mkBwrapJail {
        package = pi-coding-agent;
        bwrapFlags = [
          ''--bind "$HOME/.pi" "$HOME/.pi"''
        ];
      })

      boxlite

      allure
      git-traverse      
      # devcontainer-standalone
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
        limits
      ];
      prompts = with pkgs.piPrompts; [
        git-commit
      ];
      skills = with pkgs.piSkills; [
        conductor.conductor-setup
        conductor.conductor-implement
        conductor.conductor-new-track
        conductor.conductor-status
        conductor.conductor-revert
        browser.browser-tools
      ];
    };
    
  };
}
