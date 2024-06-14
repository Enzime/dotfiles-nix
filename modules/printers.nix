{
  imports = [ "avahi" ];

  nixosModule = { user, pkgs, ... }: {
    services.printing.enable = true;
    services.printing.stateless = true;
  };
}
