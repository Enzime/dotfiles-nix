{
  nixosModule = { config, ... }: {
    networking.networkmanager.enable = true;
  };
}
