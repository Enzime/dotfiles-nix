self: super: {
  goocanvas3 = super.goocanvas3.overrideAttrs (old: {
    # https://github.com/NixOS/nixpkgs/pull/374429/commits/24025e8fcfc3481b95dcb71593ca1ac2b8305965
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        url =
          "https://gitlab.gnome.org/Archive/goocanvas/-/commit/d025d0eeae1c5266063bdc1476dbdff121bcfa57.patch";
        hash = "sha256-9uqqC1uKZF9TDz5dfDTKSRCmjEiuvqkLnZ9w6U+q2TI=";
      })
    ];
  });

  gramps = super.gramps.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ self.goocanvas3 ];
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ])
      ++ [ super.graphviz ];
  });
}
