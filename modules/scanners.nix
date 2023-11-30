{
  nixosModule = { user, pkgs, ... }: {
    hardware.sane.enable = true;

    users.users.${user}.extraGroups = [ "scanner" ];

    environment.systemPackages =
      builtins.attrValues { inherit (pkgs.gnome) simple-scan; };
  };
}
