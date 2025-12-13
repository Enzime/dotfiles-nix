self: super: {
  ranger = super.ranger.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ])
      ++ [ super.xclip ];

    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "fix-ctrl-arrows.patch";
        url =
          "https://github.com/Enzime/ranger/commit/9e60541f3e360e2019d0b671852249771b843761.patch";
        hash = "sha256-R3Qia9++n8SC/fG72GwLYbjwmx/oyEm5BfC2/6nziqI=";
      })
    ];
  });
}
