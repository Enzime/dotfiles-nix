{
  imports = [ "graphical" "i18n" "ios" "mullvad" "pim" ];

  darwinModule = { pkgs, lib, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) apparency; };

    launchd.user.agents.install-flighty = {
      command = "${lib.getExe pkgs.mas} install 1358823008";
      serviceConfig.RunAtLoad = true;
    };
  };

  nixosModule = { host, lib, utils, ... }:
    lib.mkIf (host != "phi") {
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
      home.packages = builtins.attrValues ({
        inherit (pkgs) gh gramps nixpkgs-review;
      } // optionalAttrs ((hostPlatform.isLinux && hostPlatform.isx86_64)
        || hostPlatform.isDarwin) {
          # not currently built for `aarch64-linux`
          joplin-desktop =
            assert (hostPlatform.isLinux && hostPlatform.isAarch64)
              -> !pkgs.joplin-desktop.meta.available;
            pkgs.joplin-desktop;
        }
        // optionalAttrs hostPlatform.isDarwin { inherit (pkgs) sequential; });

      programs.firefox.profiles.personal.isDefault = true;

      home.file."Documents/iCloud" = lib.mkIf hostPlatform.isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/Library/Mobile Documents/com~apple~CloudDocs/Documents";
      };

      preservation.directories = [ ".config/joplin-desktop" ".gramps" ];
    };
}
