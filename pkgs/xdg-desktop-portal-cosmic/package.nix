{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  glib,
  just,
  libcosmicAppHook,
  pkg-config,
  util-linux,
  libgbm,
  pipewire,
  gst_all_1,
  cosmic-wallpapers,
  nix-update-script,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xdg-desktop-portal-cosmic";
  version = "1.12.0-unstable-2026-11-24";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "xdg-desktop-portal-cosmic";
    rev = "e046d1f29669e24d76fa7042e88e91dca8cdb782";
    hash = "sha256-GP9IQ5U1qdLt8UJTO4F4cCwcYGS7qDCfVlfN55agzq4=";
  };

  cargoHash = "sha256-WaPa5at4IYjXa2ti4ni4kmbK8SCF59KOPsXz6RFLEJ4=";

  separateDebugInfo = true;

  __structuredAttrs = true;

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
    pkg-config
    util-linux
  ];

  buildInputs = [
    glib
    libgbm
    pipewire
  ];

  checkInputs = [ gst_all_1.gstreamer ];

  postPatch = ''
    substituteInPlace src/screenshot.rs src/widget/screenshot.rs \
      --replace-fail '/usr/share/backgrounds' '${cosmic-wallpapers}/share/backgrounds'
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
    homepage = "https://github.com/pop-os/xdg-desktop-portal-cosmic";
    description = "XDG Desktop Portal for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    mainProgram = "xdg-desktop-portal-cosmic";
    platforms = lib.platforms.linux;
  };
})
