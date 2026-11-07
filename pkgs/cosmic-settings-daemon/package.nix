{
  lib,
  fetchFromGitHub,
  stdenv,
  rustPlatform,
  makeBinaryWrapper,
  adw-gtk3,
  pkg-config,
  just,
  libpulseaudio,
  pipewire,
  libinput,
  udev,
  libxkbcommon,
  wayland,
  openssl,
  nixosTests,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-settings-daemon";
  version = "1.11.0-unstable-2026-11-06";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    rev = "2df041e6e90757782a7884729ae3723e86cee122";
    hash = "sha256-CuRFoirAX+FL5oMVnp2EDz9kkMNHgF8ylODINKWVHEU=";
  };

  postPatch = ''
    substituteInPlace src/theme.rs \
      --replace-fail '/usr/share/themes/adw-gtk3' '${adw-gtk3}/share/themes/adw-gtk3'
  '';

  cargoHash = "sha256-rEppb4hHQq/FSp/YbAQIVmUJ7v9yWgF0Vgz3DdTdjpE=";

  separateDebugInfo = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeBinaryWrapper
    just
  ];

  buildInputs = [
    libinput
    libpulseaudio
    openssl
    udev
    pipewire
    libxkbcommon
    wayland
  ];

  makeFlags = [
    "prefix=$(out)"
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

  postFixup = ''
    wrapProgram $out/bin/cosmic-settings-daemon \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
        ]
      }
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
    homepage = "https://github.com/pop-os/cosmic-settings-daemon";
    description = "Settings Daemon for the COSMIC Desktop Environment";
    mainProgram = "cosmic-settings-daemon";
    license = lib.licenses.gpl3Only;
    teams = [ lib.teams.cosmic ];
    platforms = lib.platforms.linux;
  };
})
