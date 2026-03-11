{ lib
, rustPlatform
, fetchFromGitHub
, fetchurl
, pkg-config
, openssl
, stdenv
, darwin
, go
, python3
, protobuf
}:

rustPlatform.buildRustPackage rec {
  pname = "boxlite";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "boxlite-ai";
    repo = "boxlite";
    rev = "v${version}";
    hash = "sha256-pCHpX5pXcN3g65y9+wCM52wEQRnCzmertdLvEqgQqZM=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-InMHZ0X1hH9YLcamdXLJ0C4VyJW+HOAx1DCQK5Ot7vc=";

  boxliteRuntime = fetchurl {
    url = "https://github.com/boxlite-ai/boxlite/releases/download/v${version}/boxlite-runtime-linux-x64-gnu.tar.gz";
    sha256 = "07w9bviq4wf0dcwcac6qnb71irwwnvxmklq4iyjkihx2pn1wwlhr";
  };

  preBuild = ''
    mkdir -p runtime-libs
    tar -xzf ''${boxliteRuntime} -C runtime-libs
    # create symlinks so ld can find them
    ln -s libkrun.so.1.16.0 runtime-libs/boxlite-runtime/libkrun.so
    export LIBRARY_PATH=$PWD/runtime-libs/boxlite-runtime:$LIBRARY_PATH
  '';

  postInstall = ''
    mkdir -p $out/lib $out/bin/runtime
    cp -r runtime-libs/boxlite-runtime/*.so* $out/lib/
    find runtime-libs/boxlite-runtime -maxdepth 1 -type f -not -name "*.so*" -exec cp {} $out/bin/runtime/ \;
  '';

  nativeBuildInputs = [
    pkg-config
    go
    python3
    protobuf
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  BOXLITE_DEPS_STUB = "1";

  cargoBuildFlags = [ "-p" "boxlite-cli" ];

  doCheck = false;

  meta = with lib; {
    description = "A lightweight AI agent runner";
    homepage = "https://github.com/boxlite-ai/boxlite";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "boxlite";
  };
}
