self: super: {
  ranger = super.ranger.overrideAttrs (old: let
    #                       (a == b)   (a > b)
    # compareVersions a b =       0  |      1
    versionAtMost = a: b: builtins.compareVersions a b > -1;
  in {
    propagatedBuildInputs = (
      assert (
        # SEE: https://github.com/NixOS/nixpkgs/pull/141466#issuecomment-942185842
        # SEE ALSO: https://github.com/ranger/ranger/issues/2404
        versionAtMost "1.9.3" old.version
      ); old.propagatedBuildInputs ++ [ super.xclip ]
    );
  });
}
