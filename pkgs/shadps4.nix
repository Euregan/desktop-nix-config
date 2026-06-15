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
}:

llvmPackages_18.stdenv.mkDerivation rec {
  pname = "shadps4";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "shadPS4";
    rev = "v.${version}";
    # v.0.7.0 => "sha256-g55Ob74Yhnnrsv9+fNA1+uTJ0H2nyH5UT4ITHnrGKDo="
    # v.0.15.0 => "sha256-Y66ScZIFpQN1pRfPfj/z+H71RYkLenq8OIYBVmTD0cM="
    # v.0.16.0 => "sha256-wlFn3JZqfRBlGFnQfr0w8LoiytyUMaCAOqiG8CCtI7U="
    hash = "sha256-Y66ScZIFpQN1pRfPfj/z+H71RYkLenq8OIYBVmTD0cM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    makeWrapper
    wayland-scanner
    llvmPackages_18.clang
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
  ];

  PKG_CONFIG_PATH = "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [ libffi ]}:${lib.makeSearchPathOutput "dev" "share/pkgconfig" [ wayland-protocols ]}";

  cmakeFlags = [
    "-DSDL_X11_XTEST=OFF"
  ];

  postFixup = ''
    wrapProgram $out/bin/shadps4 \
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
      ]}
  '';

  postInstall = ''
    wrapProgram $out/bin/shadps4 \
      --set SDL_JOYSTICK_HIDAPI_STEAM_VIRTUAL_GAMEPAD 1 \
      --unset SDL_GAMECONTROLLER_IGNORE_DEVICES \
      --unset SDL_JOYSTICK_HIDAPI_STEAMXBOX \
      --set SDL_VIDEODRIVER x11
  '';

  meta = {
    description = "PlayStation 4 emulator written in C++";
    homepage = "https://github.com/shadps4-emu/shadPS4";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "shadps4";
  };
}