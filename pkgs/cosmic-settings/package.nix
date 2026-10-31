{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cmake,
  just,
  libcosmicAppHook,
  pkg-config,
  expat,
  libinput,
  fontconfig,
  freetype,
  isocodes,
  pipewire,
  pulseaudio,
  udev,
  dav1d,
  pciutils,
  desktop-file-utils,
  cosmic-randr,
  xkeyboard_config,
  nix-update-script,
  nixosTests,
}:
let
  libcosmicAppHook' = (libcosmicAppHook.__spliced.buildHost or libcosmicAppHook).override {
    includeSettings = false;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-settings";
  version = "1.11.0-unstable-2026-10-30";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings";
    rev = "d678586a0e62b907e91a1079e73f6c42358185e5";
    hash = "sha256-Cy5yDM6qjEUTl7GhW3TIXy3Jq5pZXR1ULUkVBMQFgHE=";
  };

  cargoHash = "sha256-qclfV774TJrjeWDTpNMS4WU9pLuXx1AqX+5lwmVU9Bk=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    just
    libcosmicAppHook'
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    expat
    fontconfig
    freetype
    libinput
    pipewire
    pulseaudio
    udev
    dav1d
    pciutils
    desktop-file-utils
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

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ cosmic-randr ]}
      --prefix XDG_DATA_DIRS : ${lib.makeSearchPathOutput "bin" "share" [ isocodes ]}
      --set-default X11_BASE_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.xml
      --set-default X11_BASE_EXTRA_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/extra.xml
    )
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
    description = "Settings for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-settings";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-settings";
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
