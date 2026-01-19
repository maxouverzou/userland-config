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

  options.enableGraphical = mkEnableOption "";

  config = mkIf config.enableGraphical {

    home.packages = with pkgs; [
      _1password-gui
      veracrypt
    ];

    stylix.fonts = {
      monospace.package = pkgs.nerd-fonts.fira-code;
    };

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
        "org.qgis.qgis//stable"
        "org.virt_manager.virt-manager"
        "tv.plex.PlexDesktop"

        "com.reqable.Reqable"
        "org.kde.calligra"
        "com.heroicgameslauncher.hgl"
        "com.usebottles.bottles"
        "de.zwarf.picplanner"
        "io.github.ciromattia.kcc"
        "com.calibre_ebook.calibre"

        "io.mpv.Mpv"
      ];
    };

    programs.foot = {
      enable = pkgs.stdenv.isLinux;
      package = pkgs.emptyDirectory;
      settings = {
        main.shell = "fish";
      };
    };

    programs.fish.shellAliases = {
      mpv = "flatpak run io.mpv.Mpv";
    };

  };
}
