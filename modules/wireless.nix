{
  nixosModule = { lib, ... }: {
    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkForce false;
  };
}
