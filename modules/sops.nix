{
  homeModule = { config, pkgs, lib, ... }:
    let
      platformConfigDir = if pkgs.stdenv.hostPlatform.isDarwin then
        "Library/Application Support"
      else
        config.xdg.configHome;
    in {
      home.file."${platformConfigDir}/sops/age/keys.txt".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/${platformConfigDir}/sops/age/keys.txt.1p");

      home.file."${platformConfigDir}/sops/age/keys.txt.1p".text = ''
        # Recipient: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKZfejb9htpSB5K9p0RuEowErkba2BMKaze93ZVkQIE
        AGE-PLUGIN-1P-1X2NELQ
      '';
    };
}
