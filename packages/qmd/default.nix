{
  pkgs,
  lib,
  fetchFromGitHub,
  ...
}:

let
  pname = "qmd";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "ba7391832dd6458aa1c027ab9402533ed56b5dd5";
    sha256 = "0g13za78bddq8a5899lq63fqpxxzy00hqqidvzk0g8n3i8b9r132";
  };

  bunDeps = pkgs.bun2nix.fetchBunDeps {
    bunNix = ./package-lock.nix;
  };

in
pkgs.bun2nix.mkDerivation {
  inherit
    pname
    version
    src
    bunDeps
    ;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildPhase = ''
    runHook preBuild
    bun install --offline
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/qmd
    cp -r . $out/lib/qmd
    
    makeWrapper ${pkgs.bun}/bin/bun $out/bin/qmd \
      --add-flags "run $out/lib/qmd/src/qmd.ts" \
      --set BUN_INSTALL_CACHE_DIR $out/lib/qmd/.bun-cache
    runHook postInstall
  '';

  meta = with lib; {
    description = "Quick Markdown Search - Full-text and vector search for markdown files";
    homepage = "https://github.com/tobi/qmd";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "qmd";
  };
}

