self: super: {
  spotify-tray = super.spotify-tray.overrideAttrs (old: {
    patches = [
      (super.fetchpatch {
        name = "fix-building-with-automake-1.16.5.patch";
        url = "https://github.com/tsmetana/spotify-tray/commit/1305f473ba4a406e907b98c8255f23154f349613.patch";
        sha256 = "sha256-u2IopfMzNCu2F06RZoJw3OAsRxxZYdIMnKnyb7/KBgk=";
      })
    ];

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ super.makeWrapper ];

    postInstall = ''
      mv $out/bin/spotify-tray $out/bin/spotify
      wrapProgram $out/bin/spotify \
        --add-flags "-c ${super.spotify}/bin/spotify"
    '';

    meta = old.meta // {
      priority = (super.spotify.meta.priority or 0) - 1;
    };
  });
}
