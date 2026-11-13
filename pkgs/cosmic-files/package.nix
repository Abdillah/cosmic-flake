{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  just,
  libcosmicAppHook,
  glib,
  shared-mime-info,
  nix-update-script,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-files";
  version = "1.11.0-unstable-2026-11-09";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-files";
    rev = "2c20e74a0bd01c5d24ffe730290b152a46d983be";
    hash = "sha256-xBGvfwwmoOGzUjKTNl4PS0XugEiECXfPN6GckM4MlfY=";
  };

  cargoHash = "sha256-lOAn+mCOjsurWcVw73RMlp0gLAZ1kGQjpZ1NMY38wuc=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  env.VERGEN_GIT_SHA = finalAttrs.src.rev;

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [ glib ];

  # xdg-mime needs the shared MIME database to identify archive files in the
  # operation tests.
  nativeCheckInputs = [ shared-mime-info ];

  preCheck = ''
    export XDG_DATA_DIRS="${shared-mime-info}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
  '';

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

  # This is needed since by setting cargoBuildFlags, it would build both the applet and the main binary
  # at the same time, which would cause problems with the desktop items applet
  buildPhase = ''
    runHook preBuild

    defaultCargoBuildFlags="$cargoBuildFlags"

    cargoBuildFlags="$defaultCargoBuildFlags --package cosmic-files"
    runHook cargoBuildHook

    cargoBuildFlags="$defaultCargoBuildFlags --package cosmic-files-thumbnailer"
    runHook cargoBuildHook

    cargoBuildFlags="$defaultCargoBuildFlags --package cosmic-files-applet"
    runHook cargoBuildHook

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    defaultCargoTestFlags="$cargoTestFlags"

    cargoTestFlags="$defaultCargoTestFlags --package cosmic-files"
    runHook cargoCheckHook

    cargoTestFlags="$defaultCargoTestFlags --package cosmic-files-thumbnailer"
    runHook cargoCheckHook

    cargoTestFlags="$defaultCargoTestFlags --package cosmic-files-applet"
    runHook cargoCheckHook

    runHook postCheck
  '';

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
    homepage = "https://github.com/pop-os/cosmic-files";
    description = "File Manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-files";
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
