{ lib, buildGoModule, fetchFromGitHub, go_1_26, installShellFiles, stdenv }:

buildGoModule.override { go = go_1_26; } (finalAttrs: {
  pname = "hey";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "basecamp";
    repo = "hey-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-y86pSryOZZGCQPCiprjENOeqvXejhbB3piRxy/w6WJ4=";
  };

  # Upstream's go.mod pins a newer 1.26 patch than nixpkgs' go_1_26 carries;
  # the patch bump is toolchain bugfixes only, not a language feature this
  # code needs, so relax the directive to what we actually build with.
  postPatch = ''
    sed -i "s/^go 1\.26\..*/go ${go_1_26.version}/" go.mod
  '';

  # Pulled from upstream's own nix/package.nix (vendorHash is regenerated
  # there via `make update-nix-hash` on every release).
  vendorHash = "sha256-Nupd+16J+aXwNnstS6W86jjx1Usuwsw4FJSU6tdcQ3o=";

  subPackages = [ "cmd/hey" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/basecamp/hey-cli/internal/version.Version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString
    (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd hey \
      --bash <($out/bin/hey shell-completion generate bash) \
      --fish <($out/bin/hey shell-completion generate fish) \
      --zsh  <($out/bin/hey shell-completion generate zsh)
  '';

  meta = {
    description = "Command-line interface for HEY email";
    homepage = "https://github.com/basecamp/hey-cli";
    changelog = "https://github.com/basecamp/hey-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "hey";
    platforms = lib.platforms.unix;
  };
})
