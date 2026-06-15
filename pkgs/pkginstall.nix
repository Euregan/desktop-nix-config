{ lib
, stdenv
, fetchFromGitHub
, cmake
, qt6
, makeWrapper
, xorg
, libglvnd
}:

stdenv.mkDerivation rec {
  pname = "pkginstall";
  version = "unstable-2025-10-24";

  src = fetchFromGitHub {
    owner = "Muggle345";
    repo = "PKGInstall";
    rev = "902d14c1a3c277a586e4c0c4db0774d06bda3501";
    hash = "sha256-iY8+3U271eUKAl9xgw5FZQKG6l49GkjUYJQT3fmW9os=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
  ];

  preConfigure = ''
    touch PKGInstall.desktop
    touch PKGIcon.png
  '';

  qtWrapperArgs = [
    "--set QT_QPA_PLATFORM xcb"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      xorg.libX11
      libglvnd
    ]}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp PKGInstall $out/bin/
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/512x512/apps
  '';

  meta = {
    description = "PS4 PKG installer GUI for shadPS4";
    homepage = "https://github.com/Muggle345/PKGInstall";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "PKGInstall";
  };
}