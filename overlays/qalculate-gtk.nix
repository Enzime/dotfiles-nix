self: super: {
  qalculate-gtk = super.qalculate-gtk.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (super.fetchpatch {
        name = "fix-platform-macos-conditional.patch";
        url = "https://github.com/Qalculate/qalculate-gtk/commit/f32ced1525c4cfc8e2c31b3f0d192371d1ffadc3.patch";
        hash = "sha256-v9T8wWvqlI9l6BUszf/575qmoFvh88Cdj/m2XqV8Q4k=";
      })
    ];

    buildInputs =
      assert !builtins.any (i: super.lib.getName i == "gtk-mac-integration") old.buildInputs;
      old.buildInputs
      ++ super.lib.optionals super.stdenv.hostPlatform.isDarwin [ super.gtk-mac-integration ];
  });
}
