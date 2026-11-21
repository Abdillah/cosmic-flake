{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  pkg-config,
  libinput,
  libgbm,
  udev,
  nix-update-script,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-workspaces-epoch";
  version = "1.11.0-unstable-2026-11-18";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-workspaces-epoch";
    rev = "a07763430ba2952ccd1a5c6831c68b8852634859";
    hash = "sha256-MwF5opIG2awyZ2AmW11Kgzi/PiAU0Hjn0A6HOWUFdnM=";
  };

  cargoHash = "sha256-pEmPnuwWVNSnvw17eAalhiZVjd05rt0zvOjSHlifOrE=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    libinput
    libgbm
    udev
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
    "CARGO_TARGET_DIR=target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  dontCargoInstall = true;

  passthru = {
    tests = {
      inherit (nixosTests)
        cosmic
        cosmic-autologin
        cosmic-noxwayland
        cosmic-autologin-noxwayland
        ;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "epoch-(.*)"
      ];
    };
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-workspaces-epoch";
    description = "Workspaces Epoch for the COSMIC Desktop Environment";
    mainProgram = "cosmic-workspaces";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
