self: super: {
  steam-bin =
    assert !super ? steam-bin;
    super.stdenvNoCC.mkDerivation {
      pname = "steam";
      version = "1778003620";

      src = super.fetchurl {
        url = "https://steamcdn-a.akamaihd.net/client/appdmg_osx.zip.984652b88a9737e3f4e77c656d9ffa67d5042c2c";
        hash = "sha256-i/TOi0vLxQ9kKYjJVVWfYF56h3NyEW56Kz/RNVAEvts=";
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

      passthru.updateScript = ../files/update-steam.sh;

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
