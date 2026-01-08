self: super: {
  cbr2cbz = super.callPackage ../packages/cbr2cbz.nix { };
  ccstatusline = super.callPackage ../packages/ccstatusline/default.nix { };
  cfn-normalizer = super.callPackage ../packages/cfn-normalize.nix { };
  claude-code-stable = super.callPackage ../packages/claude-code.nix { };
  devcontainer-standalone = super.callPackage ../packages/devcontainer-standalone.nix { };
  fedit = super.callPackage ../packages/fedit.nix { };
  frbi = super.callPackage ../packages/frbi.nix { };
  gpx-reduce = super.callPackage ../packages/gpx-reduce.nix { };
  hwd = super.callPackage ../packages/hwd.nix { };
  json2yaml = super.callPackage ../packages/json2yaml.nix { };
  notebooklm-mcp = super.callPackage ../packages/notebooklm-mcp/default.nix { };
  mcp-cmd = super.callPackage ../packages/mcp-cmd/default.nix { };
  jules = super.callPackage ../packages/jules.nix { };
  nlm = super.callPackage ../packages/nlm.nix { };
  ostree-interactive-deploy = super.callPackage ../packages/ostree-interactive-deploy.nix { };
  urlencode = super.callPackage ../packages/urlencode.nix { };
  redis-cli = super.callPackage ../packages/redis-cli.nix { };
  tile-stitch = super.callPackage ../packages/tile-stitch.nix { };
  yaml2json = super.callPackage ../packages/yaml2json.nix { };
}
