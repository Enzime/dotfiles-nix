{
  homeModule =
    { pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) hostPlatform;
      inherit (lib) mkIf mkDefault;
    in
    mkIf hostPlatform.isLinux {
      xdg.userDirs = {
        enable = true;
        desktop = mkDefault "$HOME";
        documents = mkDefault "$HOME";
        download = mkDefault "/data/Downloads";
        music = mkDefault "$HOME";
        pictures = mkDefault "/data/Pictures";
        publicShare = mkDefault "$HOME";
        templates = mkDefault "$HOME";
        videos = mkDefault "$HOME";
      };
    };
}
