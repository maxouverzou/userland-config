{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cbr2cbz
    veracrypt
    yubikey-personalization
  ];
}
