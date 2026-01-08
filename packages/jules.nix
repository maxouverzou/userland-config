{
  stdenv,
  fetchurl,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "jules";
  version = "0.1.42";

  src =
    let
      system = stdenv.hostPlatform.parsed.kernel.name;
      arch = stdenv.hostPlatform.parsed.cpu.name;

      goPlatform = {
        "linux" = "linux";
        "darwin" = "darwin";
        "windows" = "windows";
      }.${system} or (throw "Unsupported system: ${system}");

      goArch = {
        "x86_64" = "amd64";
        "aarch64" = "arm64";
      }.${arch} or (throw "Unsupported architecture: ${arch}");
    in
    fetchurl {
      url = "https://storage.googleapis.com/jules-cli/v${version}/jules_external_v${version}_${goPlatform}_${goArch}.tar.gz";
      sha256 = "sha256-c869LI+Jubsk703MuM15Q8y2npmzfeJnwvV5Mjen0QM=";
    };

  installPhase = ''
    tar -xzf $src
    install -D jules $out/bin/jules
  '';

  meta = {
    description = "Jules, the asynchronous coding agent from Google, in the terminal.";
    homepage = "https://jules.google";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
