self: super: {
  gramps = super.gramps.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ super.goocanvas3 ];
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ super.graphviz ];
  });
}
