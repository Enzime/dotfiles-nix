self: super: {
  spotify-tray = super.spotify-tray.overrideAttrs (old: {
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
