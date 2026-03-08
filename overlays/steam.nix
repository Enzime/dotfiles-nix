self: super: {
  steam-bin =
    assert !super ? steam-bin;
    super.stdenvNoCC.mkDerivation {
      pname = "steam";
      version = "1769025840";

      src = super.fetchurl {
        url = "https://steamcdn-a.akamaihd.net/client/appdmg_osx.zip.391cd59d411530a3881267f0c4dfb276dba95838";
        hash = "sha256-5sfhL4mGILMtvGKFqqObWwthazNsTVE7vg9vnve0lug=";
      };

      # The fetched file has a hash suffix but is actually a zip
      unpackPhase = ''
        unzip $src
      '';

      sourceRoot = ".";

      nativeBuildInputs = [
        super.unzip
        super.libarchive
      ];

      installPhase = ''
        mkdir -p $out/Applications
        # Use bsdtar to preserve extended attributes needed for code signing
        bsdtar xzf SteamMacBootstrapper.tar.gz -C $out/Applications

      '';

      # Don't strip/patch binaries - would break code signatures
      dontFixup = true;

      meta = {
        description = "Steam client for macOS with native Apple Silicon support";
        homepage = "https://store.steampowered.com";
        license = super.lib.licenses.unfree;
        platforms = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        sourceProvenance = [ super.lib.sourceTypes.binaryNativeCode ];
      };
    };
}
