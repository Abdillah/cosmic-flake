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
  version = "1.9.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-icons";
    rev = "343c007f37cd71716e68f01c43ecf2764b7f7c47";
    hash = "sha256-IlWVDJZBDn0RZaWpMx+mVJrcn5eqz2i6qDIjvQjkTZ4=";
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
