{
  darwinModule = {
    system.defaults.iCal.CalendarSidebarShown = true;
    system.defaults.iCal."first day of week" = "System Setting";
    system.defaults.iCal."TimeZone support enabled" = true;
  };

  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) gnome-calendar gnome-contacts gnome-control-center;
    };

    services.gnome.gnome-online-accounts.enable = true;
    services.gnome.evolution-data-server.enable = true;
  };
}
