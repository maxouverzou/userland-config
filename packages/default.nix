{ pkgs }:
{
  cbr2cbz = pkgs.callPackage ./cbr2cbz.nix { };
  ccstatusline = pkgs.callPackage ./ccstatusline/default.nix { };
  cfn-normalizer = pkgs.callPackage ./cfn-normalize.nix { };
  chrome-devtools-mcp = pkgs.callPackage ./chrome-devtools-mcp/default.nix { };
  claude-code-stable = pkgs.callPackage ./claude-code.nix { };
  devcontainer-standalone = pkgs.callPackage ./devcontainer-standalone.nix { };
  fedit = pkgs.callPackage ./fedit.nix { };
  frbi = pkgs.callPackage ./frbi.nix { };
  gemini-podman = pkgs.callPackage ./gemini-podman.nix { };
  gpx-reduce = pkgs.callPackage ./gpx-reduce.nix { };
  hwd = pkgs.callPackage ./hwd.nix { };
  json2yaml = pkgs.callPackage ./json2yaml.nix { };
  notebooklm-mcp = pkgs.callPackage ./notebooklm-mcp/default.nix { };
  mcp-cmd = pkgs.callPackage ./mcp-cmd/default.nix { };
  jules = pkgs.callPackage ./jules.nix { };
  nlm = pkgs.callPackage ./nlm.nix { };
  ostree-interactive-deploy = pkgs.callPackage ./ostree-interactive-deploy.nix { };
  qmd = pkgs.callPackage ./qmd/default.nix { };
  urlencode = pkgs.callPackage ./urlencode.nix { };
  redis-cli = pkgs.callPackage ./redis-cli.nix { };
  tile-stitch = pkgs.callPackage ./tile-stitch.nix { };
  yaml2json = pkgs.callPackage ./yaml2json.nix { };
}
