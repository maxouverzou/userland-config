{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    mkAfter
    mkEnableOption
    mkIf
    mkOrder
    mkPackageOption
    ;
  cfg = config.programs.glow;
  bashIntegration = ''
    eval "$(${getExe cfg.package} completion bash)"
  '';
  fishIntegration = ''
    ${getExe cfg.package} completion fish | source
  '';
  zshIntegration = ''
    eval "$(${getExe cfg.package} completion zsh)"
  '';
in
{

  options.programs.glow = {
    enable = mkEnableOption "";
    package = mkPackageOption pkgs "glow" { };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash.initExtra = mkOrder 200 bashIntegration;
    programs.fish.interactiveShellInit = mkAfter fishIntegration;
    programs.zsh.initContent = mkOrder 910 zshIntegration;
  };
}
