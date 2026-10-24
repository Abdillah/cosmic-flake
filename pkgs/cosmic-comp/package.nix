{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  pkg-config,
  libdisplay-info,
  just,
  libgbm,
  libinput,
  pixman,
  seatd,
  udev,
  systemd,
  xrdb,
  nix-update-script,
  nixosTests,

  useSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  useXWayland ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-comp";
  version = "1.11.0-unstable-2026-10-20";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    rev = "8cb1802caada438bb5cc7670dfabdaca5fad0502";
    hash = "sha256-1uQuMd/SUuO7oURiTmQeH8Sxe4rcBxr1surCIZXDjyw=";
  };

  cargoHash = "sha256-cN0S7UvJQwUDOfF0xcBML0N0q8pWcG/0cOL7JwnlBbQ=";

  # Only default feature is systemd
  buildNoDefaultFeatures = !useSystemd;

  separateDebugInfo = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
    just
  ];

  buildInputs = [
    libdisplay-info
    libgbm
    libinput
    pixman
    seatd
    udev
  ]
  ++ lib.optional useSystemd systemd;

  makeFlags = [
    "prefix=${placeholder "out"}"
    "CARGO_TARGET_DIR=target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  dontCargoInstall = true;
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  # 1.9.0 and earlier use a Makefile, newer versions use just.
  installPhase = ''
    runHook preInstall
    if [[ -f justfile ]]; then
      just "''${justFlags[@]}" install
    else
      make "''${makeFlags[@]}" install
    fi
    runHook postInstall
  '';

  # With Xwayland, cosmic-comp calls out to `xrdb -merge` to set
  # `Xcursor.size` and `Xcursor.theme` for X11 clients (src/xwayland.rs,
  # upstream pop-os/cosmic-comp#1976). Without it on PATH it logs
  # "`xrdb` not found, cannot update Xresources." and X11 clients fall back
  # to libXcursor's screen-derived default cursor size.
  preFixup = lib.optionalString useXWayland ''
    libcosmicAppWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ xrdb ]})
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
    homepage = "https://github.com/pop-os/cosmic-comp";
    description = "Compositor for the COSMIC Desktop Environment";
    mainProgram = "cosmic-comp";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
