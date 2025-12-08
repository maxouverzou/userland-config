{
  stdenv,
  fetchurl,
  lib,
  makeWrapper,
  electron,
  makeDesktopItem,
  imagemagick,
  writeScript,
  commandLineArgs ? "",
  featureFlags ? null
}:

let
  pname = "lobe-chat";
  version = "1.143.2";
  appname = "LobeChat";
  meta = with lib; {
    description = "An open-source, extensible (Function Calling), high-performance chatbot framework. It supports one-click free deployment of your private ChatGPT/LLM web application.";
    homepage = "https://github.com/lobehub/lobe-chat";
    downloadPage = "https://github.com/lobehub/lobe-chat/releases";
    mainProgram = "lobe-chat";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };

  src = fetchurl {
    url = "https://github.com/lobehub/lobe-chat/releases/download/v${version}/lobehub-desktop-beta-${version}.tar.gz";
    hash = "sha256-fKemmwIdQtgikTfduhm5xfAhEm1b7fmrcDVNyZdf7j0=";
  };

  icon = fetchurl {
    url = "https://github.com/lobehub/lobe-chat/blob/next/public/icons/icon-512x512.png";
    hash = "sha256-+2pTLG1DP99MYzDQkc1XWiFGPDY8e2clJgTjQIqK7mI=";
  };

  desktopItem = makeDesktopItem {
    name = "lobe-chat";
    desktopName = "Lobe Chat";
    comment = meta.description;
    icon = "lobe-chat";
    exec = "lobe-chat %u";
    categories = [ "Office" ];
    mimeTypes = [ "x-scheme-handler/lobe-chat" ];
  };

in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    desktopItem
    icon
    ;

  sourceRoot = "lobehub-desktop-beta-${version}";

  meta = meta // {
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  nativeBuildInputs = [
    makeWrapper
    imagemagick
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    makeWrapper ${electron}/bin/electron $out/bin/lobe-chat \
      --add-flags $out/share/lobe-chat/app.asar \
      --add-flags "''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    install -m 444 -D resources/app.asar $out/share/lobe-chat/app.asar

    install -m 444 -D "${desktopItem}/share/applications/"* \
      -t $out/share/applications/

    #for size in 16 24 32 48 64 128 256 512; do
    #  mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
    #  magick -background none ${icon} -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/lobe-chat.png
    #done
    runHook postInstall
  '';

  postInstall = lib.optionalString (featureFlags != null) ''
    wrapProgram $out/bin/lobe-chat --set FEATURE_FLAGS "${featureFlags}"
  '';
}
