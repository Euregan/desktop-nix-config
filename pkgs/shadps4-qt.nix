{ lib
, llvmPackages_18
, fetchFromGitHub
, cmake
, pkg-config
, git
, makeWrapper
, libffi
, alsa-lib
, libpulseaudio
, openal
, zlib
, libedit
, udev
, libevdev
, jack2
, sndio
, vulkan-loader
, vulkan-headers
, ffmpeg
, libxkbcommon
, wayland
, wayland-protocols
, wayland-scanner
, libpng
, xorg
, libglvnd
, libuuid
, util-linux
, qt6
}:

llvmPackages_18.stdenv.mkDerivation rec {
  pname = "shadps4-qt";
  version = "224";

  src = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "shadPS4-qtlauncher";
    rev = "v${version}";
    hash = "sha256-KBjAP0t2A6Q0eD7A0/9HzIQrUJ97YUkx2nx4SB+poHU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    makeWrapper
    wayland-scanner
    llvmPackages_18.clang
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    libpulseaudio
    openal
    udev
    libevdev
    jack2
    sndio
    vulkan-loader
    vulkan-headers
    libpng
    zlib
    libedit
    ffmpeg
    libffi
    libxkbcommon
    wayland
    wayland-protocols
    xorg.libX11
    xorg.libXext
    xorg.libXrandr
    xorg.libXi
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilkeysyms
    xorg.xcbutilwm
    libglvnd
    libuuid
    util-linux
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qttools
  ];

  PKG_CONFIG_PATH = "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [ libffi ]}:${lib.makeSearchPathOutput "dev" "share/pkgconfig" [ wayland-protocols ]}";

  cmakeFlags = [
    "-DENABLE_QT_GUI=ON"
    "-DSDL_X11_XTEST=OFF"
  ];

  postFixup = ''
    wrapProgram $out/bin/shadPS4QtLauncher \
      --set QT_QPA_PLATFORM xcb \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        xorg.libX11
        xorg.libXext
        xorg.libXrandr
        xorg.libXi
        xorg.libXcursor
        xorg.libXfixes
        xorg.libXScrnSaver
        xorg.libXtst
        libglvnd
        vulkan-loader
        qt6.qtbase
        qt6.qtmultimedia
      ]}
  '';

  meta = {
    description = "PlayStation 4 emulator Qt launcher";
    homepage = "https://github.com/shadps4-emu/shadps4-qtlauncher";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "shadPS4QtLauncher";
  };
}