{
  config,
  lib,
  pkgs,
  ...
}:
{

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # nixgl.nixGLIntel
    # nixgl.nixVulkanIntel
    # ^ these should be used directly within patched desktop entries?
    # ^ not needed at the moment; does not work on darwin

    cfn-normalizer
    fedit
    frbi # interactive git rebase
    hvd # homemanager diff tool
    json2yaml
    yaml2json

    _1password-cli
    awscli2
    btop # htop replacement
    devenv # declarative/reproducible developer environments
    dig # dns utils
    fd # alternative to find
    file
    llm # access LLMs from the command-line
    ncdu # ncurses disk usage analyzer
    nix-your-shell # fish/zsh support for nix-shell
    nixfmt-rfc-style
    parallel # TODO is rust-parallel ready?
    pbzip2 # parallel bzip2
    pigz # parallel gzip
    pixz # parallel xz
    pv
    rclone # sync files & directories to/from cloud
    restic # backup program
    screen
    terminal-parrot
    tig # text-mode interface for git
    tmate # terminal sharing
    watchman
    whois
    xan # process csv files
    xxd

    # move these to a different category?
    cbr2cbz
    yubikey-personalization
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "${pkgs.helix}/bin/hx";
    SUDO_EDITOR = "${pkgs.helix}/bin/hx";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.eza = {
    enable = true;
    icons = "auto";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      nix-your-shell fish | source

      complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
    '';
    plugins = [
      #{
      #  name = "fzf";
      #  src = pkgs.fishPlugins.fzf-fish.src;
      #}
      {
        name = "you-should-use";
        src = pkgs.fishPlugins.fish-you-should-use.src;
      }

      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];
  };
  programs.fzf.enable = true;
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        features = "decorations";
        naviguate = true;
        light = false;
        side-by-side = true;
      };
    };
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
  programs.helix.enable = true;
  programs.jq.enable = true;
  programs.jqp.enable = true;
  programs.tealdeer.enable = true;
  programs.ripgrep.enable = true;
  # use command-not-found instead?
  programs.nix-index.enable = true;
  programs.lazygit.enable = true;
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      status.disabled = false;
      username = {
        format = "[$user]($style) ";
        disabled = false;
        show_always = false;
      };
      hostname = {
        ssh_only = true;
        # ssh_symbol = "🌐 ";
        trim_at = ".local";
        disabled = false;
      };
    };
  };
  programs.yt-dlp.enable = true;
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    settings.default_shell = "fish";
  };
  programs.zsh.enable = pkgs.stdenv.isDarwin;

  services.syncthing.enable = true;

}
