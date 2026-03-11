{ pkgs }:
{
  boxlite = pkgs.callPackage ./boxlite.nix { };
  cbr2cbz = pkgs.callPackage ./cbr2cbz.nix { };
  cclimits = pkgs.callPackage ./cclimits.nix { };
  ccstatusline = pkgs.callPackage ./ccstatusline/default.nix { };
  cfn-normalizer = pkgs.callPackage ./cfn-normalize.nix { };
  chrome-devtools-mcp = pkgs.callPackage ./chrome-devtools-mcp/default.nix { };
  claude-code-stable = pkgs.callPackage ./claude-code.nix { };
  devcontainer-standalone = pkgs.callPackage ./devcontainer-standalone.nix { };
  fedit = pkgs.callPackage ./fedit.nix { };
  frbi = pkgs.callPackage ./frbi.nix { };
  gitu = pkgs.callPackage ./gitu.nix { };
  gemini-podman = pkgs.callPackage ./gemini-podman.nix { };
  git-traverse = pkgs.callPackage ./git-traverse.nix { };
  gpx-reduce = pkgs.callPackage ./gpx-reduce.nix { };
  hwd = pkgs.callPackage ./hwd.nix { };
  json2yaml = pkgs.callPackage ./json2yaml.nix { };
  mcporter = pkgs.callPackage ./mcporter/default.nix { };
  jules = pkgs.callPackage ./jules.nix { };
  nlm = pkgs.callPackage ./nlm.nix { };
  ostree-interactive-deploy = pkgs.callPackage ./ostree-interactive-deploy.nix { };
  qmd = pkgs.callPackage ./qmd/default.nix { };
  urlencode = pkgs.callPackage ./urlencode.nix { };
  redis-cli = pkgs.callPackage ./redis-cli.nix { };
  resume-markdown = pkgs.callPackage ./resume-markdown.nix { };
  skills = pkgs.callPackage ./skills/default.nix { };
  tile-stitch = pkgs.callPackage ./tile-stitch.nix { };
  yaml2json = pkgs.callPackage ./yaml2json.nix { };
}
