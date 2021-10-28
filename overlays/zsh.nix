self: super: {
  zsh = super.zsh.overrideAttrs (old: {
    # SEE: https://github.com/ohmyzsh/ohmyzsh/issues/9264
    patches = old.patches ++ [
      ./zsh_fix-git-stash-drop-completions.patch
    ];
  });
}
