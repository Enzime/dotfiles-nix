self: super: {
  sequential = assert !super ? sequential;
    super.stdenv.mkDerivation (finalAttrs: {
      pname = "sequential";
      version = "2.6.0";

      src = let buildDate = "2024-09-07.14.59.00";
      in super.fetchurl {
        url =
          "https://github.com/chuchusoft/Sequential/releases/download/v${finalAttrs.version}/Sequential.app.${buildDate}.tar.xz";
        hash = "sha256-tgpzMAHw266UhKo43GIHFCx/SDq/zIJkWz1TPYTeTzI=";
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications/Sequential.app
        cp -R Sequential.app $out/Applications

        runHook postInstall
      '';
    });
}
