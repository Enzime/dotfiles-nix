{
  imports = [ "avahi" ];

  nixosModule = { pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) libimobiledevice; };

    # For connecting to iOS devices
    services.usbmuxd.enable = true;

    # Taken directly from:
    # https://github.com/NixOS/nixpkgs/blob/HEAD/nixos/modules/services/networking/shairport-sync.nix#L74-L93
    networking.firewall.allowedTCPPorts = [ 5000 ];
    networking.firewall.allowedUDPPortRanges = [{
      from = 6001;
      to = 6011;
    }];
  };

  hmModule = { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      systemd.user.services.shairport-sync = {
        Unit = {
          Description = "shairport-sync";
          After = [
            "network.target"
            "avahi-daemon.service"
            "pipewire-pulse.service"
          ];
        };
        Service = {
          # Arguments are taken directly from:
          # https://github.com/NixOS/nixpkgs/blob/HEAD/nixos/modules/services/networking/shairport-sync.nix#L32
          ExecStart = "${lib.getExe pkgs.shairport-sync} -v -o pa";
          RuntimeDirectory = "shairport-sync";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
}
