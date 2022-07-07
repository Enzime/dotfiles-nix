{
  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.gnome) gnome-contacts gnome-control-center;
    };

    services.gnome.gnome-online-accounts.enable = true;

    age.secrets.etesync-dav.file = ../secrets/etesync-dav.age;
    age.secrets.etesync-dav.owner = user;
  };

  hmModule = { osConfig, lib, ... }@args: let
    inherit (lib) hasAttrByPath mkIf mkVMOverride;
  in mkIf (hasAttrByPath [ "osConfig" "age" ] args) {
    services.etesync-dav.enable = true;
    systemd.user.services.etesync-dav.Service.Environment = lib.mkForce [ ];
    systemd.user.services.etesync-dav.Service.EnvironmentFile = args.osConfig.age.secrets.etesync-dav.path;
  };
}
