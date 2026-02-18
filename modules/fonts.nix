{
  homeModule =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues { inherit (pkgs) dejavu_fonts noto-fonts-cjk-sans; };

      # Allow fonts to be specified in `home.packages`
      fonts.fontconfig.enable = true;
    };
}
