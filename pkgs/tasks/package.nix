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
  version = "0.4.2-unstable-2026-11-27";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tasks";
    rev = "121ae5f070c62dc3ee2dfdea7b68851fee9ad4d0";
    hash = "sha256-wC4HEwgRpXjl457Zq+ZyuXizj4QNkbGNHbX14NMFLoc=";
  };

  cargoHash = "sha256-qllm4M6NTqbaCrJ5BQl9T6uh9sHLzeQBU6pe8t4yxy8=";

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
