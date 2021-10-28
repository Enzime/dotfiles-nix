self: super: {
  zsh = super.zsh.overrideAttrs (old: {
    # SEE: https://github.com/ohmyzsh/ohmyzsh/issues/9264
    patches = old.patches ++ [
      (super.fetchpatch {
        name = "fix-git-stash-drop-completions.patch";
        url = "https://github.com/zsh-users/zsh/commit/754658aff38e1bdf487c58bec6174cbecd019d11.patch";
        sha256 = "sha256-ud/rLD+SqvyTzT6vwOr+MWH+LY5o5KACrU1TpmL15Lo=";
        excludes = [ "ChangeLog" ];
      })
    ];
  });
}
