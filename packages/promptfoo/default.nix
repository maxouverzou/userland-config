{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "promptfoo";
  version = "0.121.2";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/promptfoo/-/promptfoo-${version}.tgz";
    hash = "sha256-vAH6HVW7Q3CJG6I/fupwyFIl8rglDK3xAQGAIrzBH0E=";
  };

  npmDeps = pkgs.fetchNpmDeps {
    src = ./.;
    hash = "sha256-IU5igq/ZEUS6t0UtpXnZ97A+641mboVoSTOVomBy4vA=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = with pkgs; [ python3 pkg-config nodePackages.node-gyp ];

  PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  npmFlags = [ "--ignore-scripts" ];

  postBuild = ''
    pushd node_modules/better-sqlite3
    node-gyp rebuild --nodedir=${pkgs.nodejs}/include/node
    popd
  '';

  dontNpmBuild = true;

  meta = with lib; {
    description = "Test and evaluate LLM apps";
    homepage = "https://github.com/promptfoo/promptfoo";
    license = licenses.mit;
    maintainers = [];
  };
}
