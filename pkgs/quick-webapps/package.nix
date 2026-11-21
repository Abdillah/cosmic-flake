{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,

  just,
  pkg-config,
  makeBinaryWrapper,
  libcosmicAppHook,

  libxkbcommon,
  openssl,
  wayland,

  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "quick-webapps";
  version = "3.0.0-unstable-2026-11-20";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "web-apps";
    rev = "895da1b88fffaf2787280e99683b954611b877cf";
    hash = "sha256-+x4l5jVayvTCIQugbf1F8VvrF3Rb1hBuC1XEgcJZMQ0=";
  };

  cargoHash = "sha256-mKSUYLSPGIeOL50IkxcbQK0/Ol7APpFBgsQQ4LdFhHY=";

  nativeBuildInputs = [
    just
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [
    libxkbcommon
    openssl
  ];

  env.VERGEN_GIT_SHA = finalAttrs.src.rev;

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "PREFIX"
    (placeholder "out")
    "--set"
    "BIN_SRC"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/webapps"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Web App Manager for the COSMIC desktop";
    homepage = "https://github.com/cosmic-utils/web-apps";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ pluiedev ];
    mainProgram = "dev.heppen.webapps";
  };
})
