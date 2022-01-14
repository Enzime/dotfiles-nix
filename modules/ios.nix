{
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) libimobiledevice;
    };

    # For connecting to iOS devices
    services.usbmuxd.enable = true;
  };

  hmModule = { pkgs, ... }: {
    systemd.user.services.shairport-sync = {
      Unit = {
        Description = "shairport-sync";
        After = [ "network.target" "avahi-daemon.service" ];
      };
      Service = {
        # Arguments are taken directly from:
        # https://github.com/NixOS/nixpkgs/blob/HEAD/nixos/modules/services/networking/shairport-sync.nix#L32
        ExecStart = "${pkgs.shairport-sync}/bin/shairport-sync -v -o pa";
        RuntimeDirectory = "shairport-sync";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
