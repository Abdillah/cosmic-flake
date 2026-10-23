{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  just,
  pop-icon-theme,
  hicolor-icon-theme,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cosmic-icons";
  version = "1.11.0-unstable-2026-09-30";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-icons";
    rev = "f1a282a0822aed1f0083dd2ab2e6c65bd5b401eb";
    hash = "sha256-gK3DrC5jKaTntWOL7DpRXpu3rGULzU90Wn+8Prtdg9k=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [ just ];

  propagatedBuildInputs = [
    pop-icon-theme
    hicolor-icon-theme
  ];

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
  ];

  dontDropIconThemeCache = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    description = "System76 Cosmic icon theme for Linux";
    homepage = "https://github.com/pop-os/cosmic-icons";
    license = with lib.licenses; [
      cc-by-sa-40
    ];
    teams = [ lib.teams.cosmic ];
  };
})
