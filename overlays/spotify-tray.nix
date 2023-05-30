self: super: {
  spotify-tray = super.spotify-tray.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ super.makeWrapper ];

    postInstall = ''
      cp ${
        super.writeShellScript "spotify-wrapper" ''
          if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
            exec ${super.spotify}/bin/spotify "$@"
          else
            exec $out/bin/spotify-tray "$@"
          fi
        ''
      } $out/bin/spotify

      substituteInPlace $out/bin/spotify --replace \$out $out

      wrapProgram $out/bin/spotify-tray \
        --set-default GDK_BACKEND x11 \
        --add-flags "-c ${super.spotify}/bin/spotify"
    '';

    meta = old.meta // { priority = (super.spotify.meta.priority or 0) - 1; };
  });
}
