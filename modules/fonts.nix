{
  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) dejavu_fonts noto-fonts-cjk;
    };
  };
}
