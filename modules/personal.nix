{
  imports = [ "graphical" "i18n" "ios" "mullvad" "pim" ];

  darwinModule = { pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) apparency; };
  };

  nixosModule = { user, pkgs, utils, ... }: {
    fileSystems."/mnt/phi" = {
      device = "enzime@phi:/";
      fsType = "fuse.sshfs";
      noCheck = true;
      options = [
        "noauto"
        "x-systemd.automount"
        "_netdev"
        "IdentityFile=/etc/ssh/ssh_host_ed25519_key"
        "allow_other"
        "uid=1000"
        "gid=100"
        "ConnectTimeout=1"
        "x-systemd.mount-timeout=10s"
        "ServerAliveInterval=1"
        "ServerAliveCountMax=5"
      ];
    };

    systemd.units."${utils.escapeSystemdPath "/mnt/phi"}.mount" = {
      text = ''
        [Unit]
        StartLimitIntervalSec=0
      '';
      overrideStrategy = "asDropin";
    };
  };

  homeModule = { config, pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) hostPlatform;
      inherit (lib) optionalAttrs;
    in {
      home.packages = builtins.attrValues (optionalAttrs hostPlatform.isLinux {
        # Currently broken on macOS
        inherit (pkgs) gramps;
      } // optionalAttrs (hostPlatform.isLinux && hostPlatform.isx86_64) {
        inherit (pkgs) joplin-desktop;
      });

      programs.firefox.profiles.personal.isDefault = true;
    };
}
