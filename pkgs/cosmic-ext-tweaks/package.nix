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
  version = "0.2.5-unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tweaks";
    rev = "5548414a6dc3753cc54b3939b05f9e5ff35b1e93";
    hash = "sha256-LYz4wSsbhFxyBpVMDxF1cKy0xyx6B+M4Wr79LTmPJzk=";
  };

  cargoHash = "sha256-8pGMau1XeAM4OAVSJH2r+N+X8fEuvuEqf0g+zeiTRM0=";

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
