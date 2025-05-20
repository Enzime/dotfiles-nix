{
  nixosModule = { lib, ... }: {
    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkForce false;

    preservation.preserveAt."/persist".directories = [{
      directory = "/etc/NetworkManager/system-connections";
      mode = "0700";
    }];
  };
}
