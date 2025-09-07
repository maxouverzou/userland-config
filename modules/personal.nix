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

  options.enablePersonal = mkEnableOption "";

  config = mkIf config.enablePersonal {
    programs.rclone = {
      enable = true;
      remotes = {
        gdrive = {
          config = {
            type = "drive";
            scope = "drive";
          };
          secrets = {
            client_id = config.sops.secrets.RCLONE_GDRIVE_CLIENT.path;
            client_secret = config.sops.secrets.RCLONE_GDRIVE_SECRET.path;
          };
          mounts.documents = {
            enable = true;
            mountPoint = "/home/maxou/Documents/GDrive";
          };
        };
      };     
    };
  };
}
