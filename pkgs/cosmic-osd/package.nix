{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  pulseaudio,
  pipewire,
  libinput,
  udev,
  nix-update-script,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-osd";
  version = "1.12.0-unstable-2026-11-24";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-osd";
    rev = "3d8f746c02a3720a713bad0ec2fa21d280f2ed81";
    hash = "sha256-psA8Q6qAFo/jLweOLHUfoxfs+KoqBHdPVy562lCGNLc=";
  };

  cargoHash = "sha256-cfj2RPocm+i2J35Pt2dfGil2n7E0eG6Ln0s9Jj9ZqNA=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  env.POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pulseaudio
    udev
    libinput
    pipewire
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
    homepage = "https://github.com/pop-os/cosmic-osd";
    description = "OSD for the COSMIC Desktop Environment";
    mainProgram = "cosmic-osd";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
