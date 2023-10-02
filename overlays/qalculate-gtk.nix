self: super: {
  qalculate-gtk = super.qalculate-gtk.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ])
      ++ super.lib.optionals super.stdenv.isDarwin
      [ super.desktopToDarwinBundle ];
  });
}
