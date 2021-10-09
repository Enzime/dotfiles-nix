{
  nixosModule = { ... }: {
    # Allows storage devices to be controlled over D-Bus
    services.udisks2.enable = true;
    # Used as an abstraction over udisk2 by file managers
    services.gvfs.enable = true;

    # Some D-Bus errors were occuring on `switch` without this line
    programs.dconf.enable = true;
  };

  hmModule = { pkgs, ... }: {
    home.packages = [ pkgs.xfce.thunar ];

    services.udiskie.enable = true;
  };
}
