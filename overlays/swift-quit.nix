self: super: {
  swift-quit = assert !super ? swift-quit;
    super.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "swift-quit";
      version = "1.5";

      src = super.fetchurl {
        url =
          "https://github.com/onebadidea/swiftquit/releases/download/v${finalAttrs.version}/Swift.Quit.zip";
        sha256 = "sha256-pORnyxOhTc/zykBHF5ujsWEZ9FjNauJGeBDz9bnHTvs=";
      };
      dontUnpack = true;

      nativeBuildInputs = [ super.unzip ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications
        unzip -d $out/Applications $src

        runHook postInstall
      '';
    });
}
