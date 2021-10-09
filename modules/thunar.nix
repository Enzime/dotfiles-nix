{
  nixosModule = { ... }: {
    # Allows storage devices to be controlled over D-Bus
    services.udisks2.enable = true;
    # Used as an abstraction over udisk2 by file managers
    services.gvfs.enable = true;
  };

  hmModule = { pkgs, ... }: {
    home.packages = [ pkgs.xfce.thunar ];

    services.udiskie.enable = true;
  };
}
