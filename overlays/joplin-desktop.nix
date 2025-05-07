self: super: {
  joplin-desktop = if super.hostPlatform.isDarwin then
    super.joplin-desktop.overrideAttrs (old: {
      unpackPhase =
        assert (builtins.match ".*com.apple.cs.Code.*" old.unpackPhase)
          == null; ''
            runHook preUnpack
            7zz x -x'!Joplin ${old.version}/Applications' -xr'!*:com.apple.cs.Code*' $src
            runHook postUnpack
          '';
    })
  else
    super.joplin-desktop;
}
