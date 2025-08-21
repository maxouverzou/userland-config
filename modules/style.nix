{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    types
    ;
in
{
  options.enableStyle = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf config.enableStyle {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      targets = {
        gtk.enable = false; # won't this interfere w/ kde?
        kde.enable = false;
        qt.enable = false;
      };
    };
  };
}
