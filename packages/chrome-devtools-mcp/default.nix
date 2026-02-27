{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "chrome-devtools-mcp";
  version = "0.13.0";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${version}.tgz";
    hash = "sha256:054q6rwld8i051mg17wwixkm7dbzn40v1xigdka8s24pxh9yl3hn";
  };

  npmDeps = pkgs.fetchNpmDeps {
    src = ./.;
    hash = "sha256-K9MndLygq4gOMWFLsu/JtHyP1ZSWG1vUdTlvBbP2Jnw=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  PUPPETEER_SKIP_DOWNLOAD = "1";
  npmFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  meta = with lib; {
    description = "Chrome Devtools MCP";
    homepage = "https://github.com/dae/chrome-devtools-mcp";
    license = licenses.mit;
    maintainers = [];
  };
}