# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Lily Foster <lily@lily.flowers>
# Portions of this code are adapted from nixos-cosmic
# https://github.com/lilyinstarlight/nixos-cosmic
{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  just,
  bash,
  nix-update-script,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-idle";
  version = "1.12.0-unstable-2026-11-24";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-idle";
    rev = "63a1605b0d7027e88e82402623ee0373106bf806";
    hash = "sha256-aVPiZyuaruSPw9BGPg9I/UD9TZmHVpbWteE9ruYSvII=";
  };

  postPatch = ''
    substituteInPlace src/main.rs --replace-fail '"/bin/sh"' '"${lib.getExe' bash "sh"}"'
  '';

  cargoHash = "sha256-zirY87+JRrOp1eSB4kw2s0+3bm7SY78xqL4PyVhp6Lo=";

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
    description = "Idle daemon for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-idle";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-idle";
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
