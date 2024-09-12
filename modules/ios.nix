{
  nixosModule = { pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) libimobiledevice; };

    # For connecting to iOS devices
    services.usbmuxd.enable = true;
  };
}
