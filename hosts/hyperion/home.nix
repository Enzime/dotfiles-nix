{ config, pkgs, ... }:
let
  platformConfigDir = if pkgs.hostPlatform.isDarwin then
    "Library/Application Support"
  else
    config.xdg.configHome;
in {
  home.file."${platformConfigDir}/sops/age/keys.txt".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/${platformConfigDir}/sops/age/keys.txt.native";
}
