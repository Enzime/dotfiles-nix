{
  hmModule = { pkgs, lib, ... }: let
    inherit (pkgs.stdenv) hostPlatform;
  in lib.mkIf hostPlatform.isLinux {
    xdg.userDirs = {
      enable      = true;
      desktop     = "\$HOME";
      documents   = "\$HOME";
      download    = "/data/Downloads";
      music       = "\$HOME";
      pictures    = "/data/Pictures";
      publicShare = "\$HOME";
      templates   = "\$HOME";
      videos      = "\$HOME";
    };
  };
}
