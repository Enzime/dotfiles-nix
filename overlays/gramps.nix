self: super: {
  gramps = super.gramps.overrideAttrs (old: {
    nativeBuildInputs = assert builtins.all
      (pkg: pkg == null || pkg.name != super.desktopToDarwinBundle.name)
      super.gramps.nativeBuildInputs;
      old.nativeBuildInputs ++ super.lib.optionals super.hostPlatform.isDarwin
      [ super.desktopToDarwinBundle ];
    buildInputs = old.buildInputs ++ [ super.goocanvas3 ];
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ])
      ++ [ super.graphviz ];
  });
}
