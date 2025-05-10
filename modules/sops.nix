{
  homeModule = { config, pkgs, ... }:
    let
      platformConfigDir = if pkgs.hostPlatform.isDarwin then
        "Library/Application Support"
      else
        config.xdg.configHome;
    in {
      home.file."${platformConfigDir}/sops/age/keys.txt".text = ''
        # Recipient: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKZfejb9htpSB5K9p0RuEowErkba2BMKaze93ZVkQIE

        AGE-PLUGIN-1P-1X2NELQ
      '';
    };
}
