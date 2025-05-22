self: super: {
  spotify = super.spotify.overrideAttrs (finalAttrs: prevAttrs:
    if super.hostPlatform.isDarwin then {
      version = "1.2.64.408";

      src = assert super.lib.versionOlder prevAttrs.version finalAttrs.version;
        super.fetchurl {
          url =
            "https://web.archive.org/web/20250522123639/https://download.scdn.co/SpotifyARM64.dmg";
          hash = "sha256-28T+AxhnM1K6W50JUu9RdFRKsBRDTQulKK2+kk2RTMQ=";
        };
    } else {
      version = "1.2.60.564.gcc6305cb";
      rev = assert super.lib.versionOlder prevAttrs.version finalAttrs.version;
        "87";

      src = assert !prevAttrs ? rev;
        super.fetchurl {
          name = "spotify-${finalAttrs.version}-${finalAttrs.rev}.snap";
          url =
            "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_${finalAttrs.rev}.snap";
          hash =
            "sha512-hdJOko/0EHkPiNgWO+WB3nP+0MO9D2fxgM/X/Ri6fM1ODJxz3XYY84Xf2Ru6iGqdA9XUNRcd/qi+Gfaj9Ez0Ug==";
        };

      unpackPhase = assert !prevAttrs ? rev; ''
        runHook preUnpack
        unsquashfs "$src" '/usr/share/spotify' '/usr/bin/spotify' '/meta/snap.yaml'
        cd squashfs-root
        if ! grep -q 'grade: stable' meta/snap.yaml; then
          # Unfortunately this check is not reliable: At the moment (2018-07-26) the
          # latest version in the "edge" channel is also marked as stable.
          echo "The snap package is marked as unstable:"
          grep 'grade: ' meta/snap.yaml
          echo "You probably chose the wrong revision."
          exit 1
        fi
        if ! grep -q '${finalAttrs.version}' meta/snap.yaml; then
          echo "Package version differs from version found in snap metadata:"
          grep 'version: ' meta/snap.yaml
          echo "While the nix package specifies: ${finalAttrs.version}."
          echo "You probably chose the wrong revision or forgot to update the nix version."
          exit 1
        fi
        runHook postUnpack
      '';
    });
}
