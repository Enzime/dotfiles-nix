self: super: {
  kitty = super.kitty.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../files/implement-bold_is_bright.patch ];
  });
}
