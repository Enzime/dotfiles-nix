{
  nixosModule = { pkgs, ... }: {
    fonts.fonts = builtins.attrValues {
      inherit (pkgs) dejavu_fonts;
    };
  };
}
