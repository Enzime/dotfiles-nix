{
  nixosModule = {
    networking.networkmanager.enable = true;

    preservation.preserveAt."/persist".directories = [
      {
        directory = "/etc/NetworkManager/system-connections";
        mode = "0700";
      }
    ];
  };
}
