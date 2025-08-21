{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    ;
  cfg = config.programs.zellij;
in
{
  config = mkIf cfg.enable {
    programs.zellij = {
      enableFishIntegration = false;
      settings.default_shell = "fish";
    };

    xdg.configFile = mkMerge [
      {
        "zellij/layouts/dev.kdl".source = ./dev-layout.kdl;
      }
    ];
  };
}
