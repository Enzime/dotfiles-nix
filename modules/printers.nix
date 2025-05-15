{
  imports = [ "avahi" ];

  nixosModule = {
    services.printing.enable = true;
    services.printing.stateless = true;
  };
}
