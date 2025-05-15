{
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) gnome-calendar gnome-contacts gnome-control-center;
    };

    services.gnome.gnome-online-accounts.enable = true;
    services.gnome.evolution-data-server.enable = true;
  };
}
