self: super: {
  cbr2cbz = super.callPackage ../packages/cbr2cbz.nix { };
  fedit = super.callPackage ../packages/fedit.nix { };
  frbi = super.callPackage ../packages/frbi.nix { };
  gpx-reduce = super.callPackage ../packages/gpx-reduce.nix { };
  hvd = super.callPackage ../packages/hvd.nix { };
  hwd = super.callPackage ../packages/hwd.nix { };
  redis-cli = super.callPackage ../packages/redis-cli.nix { };
  tile-stitch = super.callPackage ../packages/tile-stitch.nix { };
}
