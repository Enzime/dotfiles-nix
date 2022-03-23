self: super: {
  zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "add-cd-dash-alias.patch";
        url = "https://patch-diff.githubusercontent.com/raw/sorin-ionescu/prezto/pull/1982.patch";
        sha256 = "sha256-d9pjrDzp3zsrdnJdHFnTsicemJAkUYqznWdQBddoy10=";
      })
      ../files/prezto-profile.patch
    ];
  });
}
