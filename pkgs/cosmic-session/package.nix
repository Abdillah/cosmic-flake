{
  lib,
  fetchFromGitHub,
  bash,
  rustPlatform,
  just,
  dbus,
  stdenv,
  nixosTests,
  nix-update-script,
  withLogind ? true,
  withSystemd ? true,
  withAutostart ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-session";
  version = "1.11.0-unstable-2026-11-07";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-session";
    rev = "3fe5d42eda0c3121e67a62b1f67d06f67ecbb09d";
    hash = "sha256-7+AJXz5c/FnotlB7bNWk1qcRFQPMwh9saYLY0eL0IPQ=";
  };

  postPatch = ''
    substituteInPlace data/start-cosmic \
      --replace-fail '/usr/bin/cosmic-session' "$out/bin/cosmic-session" \
      --replace-fail '/usr/bin/dbus-run-session' "${lib.getBin dbus}/bin/dbus-run-session"
    substituteInPlace data/cosmic.desktop \
      --replace-fail '/usr/bin/start-cosmic' "$out/bin/start-cosmic"
  '';

  cargoHash = "sha256-rOaYyy+HXh5fIA8AyIyS1Ix5nD7JP+fScOKeKvCIsRA=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  env.ORCA = "orca"; # get orca from $PATH

  nativeBuildInputs = [ just ];

  buildInputs = [ bash ];

  buildNoDefaultFeatures = true;
  buildFeatures =
    lib.optional withLogind "logind"
    ++ lib.optional withSystemd "systemd"
    ++ lib.optional withAutostart "autostart";
  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cosmic_dconf_profile"
    "${placeholder "out"}/etc/dconf/profile/cosmic"
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  passthru = {
    providedSessions = [ "cosmic" ];
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
    homepage = "https://github.com/pop-os/cosmic-session";
    description = "Session manager for the COSMIC desktop environment";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-session";
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
