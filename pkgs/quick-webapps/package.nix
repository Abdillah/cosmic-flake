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
  version = "3.0.0-unstable-2026-10-15";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "web-apps";
    rev = "6b0e3c206d8a69955b75efa175a617a74997fb9e";
    hash = "sha256-0rmZuSGyOmBh8/Fi5v4/Ljk6mwuFlQd7M4ls2Qx2Lls=";
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
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/quick-webapps"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Web App Manager for the COSMIC desktop";
    homepage = "https://github.com/cosmic-utils/web-apps";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ pluiedev ];
    mainProgram = "quick-webapps";
  };
})
