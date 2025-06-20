{
  pkgs,
  ...
}:
{
  imports = [
    ./terminal.nix
    ./graphical.nix
  ];

  config = {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
      targets = {
        gtk.enable = false; # won't this interfere w/ kde?
        kde.enable = false;
        qt.enable = false;
      };
    };
  };
}
