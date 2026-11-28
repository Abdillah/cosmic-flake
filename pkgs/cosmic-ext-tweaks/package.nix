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
  openssl,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-ext-tweaks";
  version = "0.2.6-unstable-2026-11-22";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tweaks";
    rev = "f9f2f13fb76983c10b898340a7687ceafb77c7a0";
    hash = "sha256-jsuWjSvtYBdpfc0EANJwbEXaSz0m02qYrh0O6Hf9yVE=";
  };

  cargoHash = "sha256-0uL07BG+E2yxQPX9oquEcojHXQfQdp3JrykN0aeL8x8=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  env.VERGEN_GIT_SHA = finalAttrs.src.rev;

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  buildInputs = [ openssl ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-tweaks"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/cosmic-utils/tweaks/releases/tag/${finalAttrs.version}";
    description = "Tweaking tool for the COSMIC Desktop Environment";
    homepage = "https://github.com/cosmic-utils/tweaks";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-ext-tweaks";
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
