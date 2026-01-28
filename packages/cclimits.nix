{ lib, stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation rec {
  pname = "cclimits";
  version = "b5209dac03796bbe5474db3bd232314a8d33f05c";

  src = fetchFromGitHub {
    owner = "cruzanstx";
    repo = "cclimits";
    rev = version;
    hash = "sha256-NWilGWjwXozp1wyCjDGScw6hocBk++EtdEiohFbmaTs=";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm755 lib/cclimits.py $out/bin/cclimits
    runHook postInstall
  '';

  meta = {
    description = "Manage Cloud Control limits";
    homepage = "https://github.com/cruzanstx/cclimits";
    license = lib.licenses.mit;
    mainProgram = "cclimits";
  };
}
