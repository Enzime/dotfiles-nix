self: super: {
  syncthing-macos = assert !super ? syncthing-macos;
    super.stdenv.mkDerivation (finalAttrs: {
      pname = "syncthing-macos";
      version = "1.29.2-2";

      src = super.fetchurl {
        url =
          "https://github.com/syncthing/syncthing-macos/releases/download/v${finalAttrs.version}/Syncthing-${finalAttrs.version}.dmg";
        hash = "sha256-KbUpc2gymxkhkpSvIpy2fF3xAKsDqHHwlfUB8BF8+Sc=";
      };

      nativeBuildInputs = [ super.undmg ];

      sourceRoot = "Syncthing.app";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications/${finalAttrs.sourceRoot}
        cp -R . $out/Applications/${finalAttrs.sourceRoot}

        runHook postInstall
      '';
    });
}
