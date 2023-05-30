self: super: {
  ripgrep = super.ripgrep.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "support-quoted-excludesfile.patch";
        url =
          "https://github.com/BurntSushi/ripgrep/commit/23ed34d50e10d77d64d0a8c233fa489950785622.diff";
        sha256 = "sha256-NNy+Yk6pkU9+/go0MzMjCQUGjqZTQI0hNCeTcbtY6uI=";
      })
    ];
  });
}
