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

    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "fix-ctrl-arrows.patch";
        url = "https://github.com/Enzime/ranger/commit/02d8c8f8500d46490d6724f92cf4e8ea89888d75.patch";
        sha256 = "sha256-P48pn4vZgwW5JOhRm07a0/57+pNwpL+0JMDeyV9BRXg=";
      })
    ];
  });
}
