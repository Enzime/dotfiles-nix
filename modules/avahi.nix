{
  nixosModule = { ... }: {
    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;
    services.avahi.nssmdns4 = true;
  };
}
