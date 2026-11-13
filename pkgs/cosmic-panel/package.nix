{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  just,
  nix-update-script,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-panel";
  version = "1.11.0-unstable-2026-11-12";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-panel";
    rev = "160a951c8c050a327bb04a7ca22d62e573338c90";
    hash = "sha256-zw4VSUT9Ca9X8x2/LX9+uT0aBwasg54uY/YGCWvPhNA=";
  };

  cargoHash = "sha256-UP3fUA+dOpuVWC+onjVsQBHqPRV94AcLpE4tBikzfjk=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

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
    homepage = "https://github.com/pop-os/cosmic-panel";
    description = "Panel for the COSMIC Desktop Environment";
    mainProgram = "cosmic-panel";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
