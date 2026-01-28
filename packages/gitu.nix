{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  git,
}:

rustPlatform.buildRustPackage rec {
  pname = "gitu";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "altsem";
    repo = "gitu";
    rev = "v${version}";
    hash = "sha256-IyjoFll6P2Jxdw34y2Xe+gSEFxzca1Xwr7DJxDxwvNs=";
  };

  cargoHash = "sha256-+Ku1q4LGY9QS29p0F8WNOXG3BhIwOXHhFP3Yk9zSkcY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  nativeCheckInputs = [
    git
  ];

  doCheck = false;

  meta = {
    description = "TUI Git client inspired by Magit";
    homepage = "https://github.com/altsem/gitu";
    changelog = "https://github.com/altsem/gitu/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "gitu";
  };
}