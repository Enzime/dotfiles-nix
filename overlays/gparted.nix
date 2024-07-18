self: super: {
  gparted = super.gparted.overrideAttrs (old:
    assert !builtins.elem "--enable-xhost-root" old.configureFlags; {
      configureFlags = old.configureFlags ++ [ "--enable-xhost-root" ];

      preFixup = old.preFixup + ''
        gappsWrapperArgs+=(
          --prefix PATH : "${super.lib.makeBinPath [ super.xorg.xhost ]}"
        )
      '';
    });
}
