self: super: {
  spotify-tray = super.spotify-tray.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ super.makeWrapper ];

    postInstall = ''
      ln -s $out/bin/spotify-tray $out/bin/spotify
      wrapProgram $out/bin/spotify-tray \
        --set-default GDK_BACKEND x11 \
        --add-flags "-c ${super.spotify}/bin/spotify"
    '';

    meta = old.meta // {
      priority = (super.spotify.meta.priority or 0) - 1;
    };
  });
}
