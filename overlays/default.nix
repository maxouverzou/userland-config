self: super: {
  cbr2cbz = super.callPackage ../packages/cbr2cbz.nix { };
  cfn-normalizer = super.callPackage ../packages/cfn-normalize.nix { };
  claude-code-stable = super.callPackage ../packages/claude-code.nix { };
  fedit = super.callPackage ../packages/fedit.nix { };
  frbi = super.callPackage ../packages/frbi.nix { };
  gpx-reduce = super.callPackage ../packages/gpx-reduce.nix { };
  hwd = super.callPackage ../packages/hwd.nix { };
  json2yaml = super.callPackage ../packages/json2yaml.nix { };
  redis-cli = super.callPackage ../packages/redis-cli.nix { };
  tile-stitch = super.callPackage ../packages/tile-stitch.nix { };
  yaml2json = super.callPackage ../packages/yaml2json.nix { };
}
