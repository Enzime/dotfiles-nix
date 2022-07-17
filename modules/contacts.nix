{
  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.gnome) gnome-contacts gnome-control-center;
    };

    services.gnome.gnome-online-accounts.enable = true;

    age.secrets.etesync-dav.file = ../secrets/etesync-dav.age;
    age.secrets.etesync-dav.owner = user;
  };

  hmModule = { lib, ... }@args: let
    inherit (lib) hasAttrByPath mkForce mkIf;
  in {
    services.etesync-dav.enable = true;

    systemd.user.services.etesync-dav.Service = mkIf (hasAttrByPath [ "osConfig" "age" ] args) {
     Environment = mkForce [ ];
      EnvironmentFile = args.osConfig.age.secrets.etesync-dav.path;
    };
  };
}
