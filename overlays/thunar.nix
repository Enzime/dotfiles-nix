self: super: {
  xfce = super.lib.recursiveUpdate super.xfce {
    thunar = super.xfce.thunar.overrideAttrs (old: {
      # WORKAROUND: https://github.com/cachix/cachix/issues/675
      preFixup = (old.preFixup or "") + ''
        rm $out/bin/Thunar
      '';
    });
  };
}
