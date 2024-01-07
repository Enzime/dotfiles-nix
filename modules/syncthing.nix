{
  nixosModule = { ... }: {
    services.syncthing.enable = true;
    services.syncthing.guiAddress = "0.0.0.0:8384";
    services.syncthing.settings = {
      devices.moto-g5-plus = {
        addresses = [ "tcp://moto-g5-plus" ];
        id = "SNFCA4P-6FNPUMD-BI62ZEI-MFRSQRP-OK6IMU2-ZN67HQH-UKPAN5I-OCTSHAU";
      };
      folders."/data/Backup/Signal" = {
        id = "7y829-o47k9";
        label = "Signal Backup";
        type = "receiveonly";
        devices = [ "moto-g5-plus" ];
        versioning = {
          type = "staggered";
          fsPath = "old";
          # Keep old versions for 14 days
          params.maxAge = toString (14 * 24 * 60 * 60);
        };
      };
    };
  };
}
