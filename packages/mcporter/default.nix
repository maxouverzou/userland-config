{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "mcporter";
  version = "0.7.3";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/mcporter/-/mcporter-${version}.tgz";
    hash = "sha256:0yhwv6j0kni7xa0izqy3lhamz7v822b5jiymy44csy6wd8fl2g6d";
  };

  npmDeps = pkgs.fetchNpmDeps {
    src = ./.;
    hash = "sha256-ukcC4B9AAapUtGArTvqRFxMlQAyUnmHXA8tYkoowPHA=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--legacy-peer-deps" ];

  dontNpmBuild = true;

  meta = with lib; {
    description = "MCP client proxy routing connections between a client and an arbitrary external server";
    homepage = "https://github.com/adhintz/mcporter";
    license = licenses.mit;
    maintainers = [];
  };
}