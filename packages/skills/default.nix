{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "skills";
  version = "1.4.1";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/skills/-/skills-${version}.tgz";
    hash = "sha256-f2hSzeUQ4dg+A1MVBamuU8NzE13ByDmMI3kMNRpQI8s=";
  };

  npmDeps = pkgs.fetchNpmDeps {
    src = ./.;
    hash = "sha256-fou5R6Je+hwzAZJvDlipFQ1N7S4nIrhWrRDS9hKd6xs=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = with lib; {
    description = "The open agent skills ecosystem";
    homepage = "https://github.com/vercel-labs/skills";
    license = licenses.mit;
    maintainers = [];
  };
}