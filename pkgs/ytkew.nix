{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, mpv
, yt-dlp
}:

rustPlatform.buildRustPackage rec {
  pname = "ytkew";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "dtDhruv";
    repo = "ytkew";
    rev = "v${version}";
    hash = "sha256-jlfyf+ltgxB4kruhhDqU+PeKjFavBIInzId7iTciqis=";
  };

  # crates.io currently 403s the plain-curl fetches that `cargoLock.lockFile`
  # (importCargoLock) makes, so this needs the `cargoHash`/fetchCargoVendor
  # path instead -- and a nixpkgs new enough that fetchCargoVendor sends an
  # identifying User-Agent (see nixpkgs#512735). Built against nixos-unstable
  # in configuration.nix for that reason.
  cargoHash = "sha256-S8PQ+58ah/swTeYlv0igxpeMTFh/+hKkLU6pP32PgvE=";

  nativeBuildInputs = [ makeWrapper ];

  # mpv and yt-dlp must be on PATH; ytkew shells out to both rather than
  # linking against them.
  postInstall = ''
    wrapProgram $out/bin/ytkew \
      --prefix PATH : ${lib.makeBinPath [ mpv yt-dlp ]}
    install -Dm644 ytkew.desktop $out/share/applications/ytkew.desktop
    install -Dm644 assets/ytkew.svg $out/share/icons/hicolor/scalable/apps/ytkew.svg
  '';

  meta = {
    description = "YouTube Music on the terminal";
    homepage = "https://github.com/dtDhruv/ytkew";
    changelog = "https://github.com/dtDhruv/ytkew/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "ytkew";
    platforms = lib.platforms.unix;
  };
}
