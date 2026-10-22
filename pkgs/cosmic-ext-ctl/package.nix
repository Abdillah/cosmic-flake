{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
  cosmic-comp,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-ext-ctl";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "cosmic-ctl";
    rev = "08b4e26ceddcba8d3df8df29ae865055a5bc3a04";
    hash = "sha256-URqNhkC1XrXYxr14K6sT3TLso38eWLMA+WplBdj52Vg=";
  };

  cargoHash = "sha256-OL1LqOAyIFFCGIp3ySdvEXJ1ECp9DgC/8mfAPo/E7k4=";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/cosmic-ctl";
  # The update script uses `branch=HEAD`, so the derivation version becomes e.g.
  # "1.6.0-unstable-2026-10-14", while the binary only reports "1.6.0".
  preVersionCheck = ''
    version="''${version%%-unstable-*}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for COSMIC Desktop configuration management";
    changelog = "https://github.com/cosmic-utils/cosmic-ctl/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/cosmic-utils/cosmic-ctl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    mainProgram = "cosmic-ctl";
    inherit (cosmic-comp.meta) platforms;
  };
})
