{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.flatpak = {
    enable = pkgs.stdenv.isLinux;

    packages = [
      "com.discordapp.Discord"
      "com.valvesoftware.Steam"
      "com.yubico.yubioath"
      "fr.handbrake.ghb"
      "md.obsidian.Obsidian"
      "org.libreoffice.LibreOffice"
      "org.openscad.OpenSCAD"
      "org.pgadmin.pgadmin4"
      "org.qbittorrent.qBittorrent"
      "org.qgis.qgis"
      "org.virt_manager.virt-manager"
      "tv.plex.PlexDesktop"

      "com.heroicgameslauncher.hgl"
      "com.usebottles.bottles"
      "de.zwarf.picplanner"
      "io.github.ciromattia.kcc"
      "com.calibre_ebook.calibre"
    ];
  };

  home.packages = with pkgs; [
    cbr2cbz
    veracrypt
    yubikey-personalization
  ];
}
