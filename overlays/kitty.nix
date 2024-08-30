self: super: {
  kitty = super.kitty.overrideAttrs (old:
    assert (builtins.match ".*NerdFonts.*" old.buildPhase) == null; {
      preBuild = (old.preBuild or "") + ''
        mkdir fonts
        cp "${
          (super.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
        }/share/fonts/truetype/NerdFonts/SymbolsNerdFontMono-Regular.ttf" fonts
      '';
    });
}
