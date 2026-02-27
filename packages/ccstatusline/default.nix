{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "ccstatusline";
  version = "2.0.23";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-${version}.tgz";
    hash = "sha256:1w8w28qgz76viy4wkqkzdlkrpbbmja4jp59rn1c4hi3vs1bnc48x";
  };

  npmDeps = pkgs.fetchNpmDeps {
    src = ./.;
    hash = "sha256-0VZhq7utTU5AgbYWAxOySR6zgDNFV5tTbVjYkCtwDFo=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = with lib; {
    description = "Claude Code Status Line";
    homepage = "https://github.com/hiteshjasani/ccstatusline";
    license = licenses.mit;
    maintainers = [];
  };
}