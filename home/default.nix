{
  pkgs,
  ...
}:
{
  imports = [
    ./programs
    ./terminal.nix
    ./graphical.nix
  ];

  config = {
    nix.gc = {
      automatic = true;
      persistent = true;
    };

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
