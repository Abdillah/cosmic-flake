{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  just,
  libsecret,
  openssl,
  sqlite,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tasks";
  version = "0.3.1-unstable-2026-10-18";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tasks";
    rev = "5a3b8ce37fa570e4f8dc0bf7c02c85208641c319";
    hash = "sha256-WbXagj6kiIW1A71pWd/Oj5KlzSCbKyuUfRgsHiCW+ck=";
  };

  cargoHash = "sha256-jM3hAphBCV6VGbrebcz8S0ssMQtPXSOwqQ0AqZn1ZZ8=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  buildInputs = [
    libsecret
    openssl
    sqlite
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/tasks"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    changelog = "https://github.com/cosmic-utils/tasks/releases/tag/${finalAttrs.version}";
    description = "Simple task management application for the COSMIC desktop";
    homepage = "https://github.com/cosmic-utils/tasks";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      GaetanLepage
      HeitorAugustoLN
    ];
    platforms = lib.platforms.linux;
    mainProgram = "tasks";
  };
})
