{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  just,
  pkg-config,
  nixosTests,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-screenshot";
  version = "1.12.0-unstable-2026-11-24";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-screenshot";
    rev = "0c7eb5779d451fe1158593fdd165345ed5f411b6";
    hash = "sha256-C7SXk2pH+v5eyCAMINlEuYz7CXx6bnfFvf+mi2urQ8M=";
  };

  cargoHash = "sha256-9qpUoiJaVCG0z/nQ8lOEiay+TzODtCXfhTjIYq3gPCM=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    just
    pkg-config
  ];

  dontUseJustBuild = true;

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
    homepage = "https://github.com/pop-os/cosmic-screenshot";
    description = "Screenshot tool for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-screenshot";
  };
})
