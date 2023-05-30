{
  nixosModule = { user, ... }: {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    users.users.${user}.extraGroups = [ "libvirtd" ];
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) virt-manager; };
  };
}
