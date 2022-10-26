{
  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.gnome) gnome-contacts gnome-control-center;
    };

    services.gnome.gnome-online-accounts.enable = true;
  };
}
