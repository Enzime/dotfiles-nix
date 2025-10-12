self: super: {
  ranger = super.ranger.overrideAttrs (old:
    let
      #                       (a == b)   (a > b)
      # compareVersions a b =       0  |      1
      versionAtMost = a: b: builtins.compareVersions a b > -1;
    in {
      propagatedBuildInputs = assert (
        # SEE: https://github.com/NixOS/nixpkgs/pull/141466#issuecomment-942185842
        # SEE ALSO: https://github.com/ranger/ranger/issues/2404
        versionAtMost "1.9.4" old.version);
        old.propagatedBuildInputs ++ [ super.xclip ];

      patches = (old.patches or [ ]) ++ [
        (super.fetchpatch {
          name = "fix-ctrl-arrows.patch";
          url =
            "https://github.com/Enzime/ranger/commit/9e60541f3e360e2019d0b671852249771b843761.patch";
          hash = "sha256-R3Qia9++n8SC/fG72GwLYbjwmx/oyEm5BfC2/6nziqI=";
        })
        (super.fetchpatch {
          name = "fix-iina-from-rifle.patch";
          url =
            "https://github.com/ranger/ranger/pull/3141/commits/c0a473ca41c2025c53859e0cf33da825025b2299.patch";
          hash = "sha256-i4nfxd0caIZWksHX8Qr0wE++Iuwa4VkId+kxBGzR3Jg=";
        })
      ];
    });
}
