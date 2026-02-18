{
  nixosModule =
    {
      options,
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        {
          config = lib.optionalAttrs (options ? clan) {
            clan.core.vars.generators.initrd-ssh = {
              files."id_ed25519".neededFor = "activation";
              files."id_ed25519.pub".secret = false;
              runtimeInputs = [
                pkgs.coreutils
                pkgs.openssh
              ];
              script = ''
                ssh-keygen -t ed25519 -N "" -C "" -f "$out/id_ed25519"
              '';
            };

            clan.core.vars.generators.hoopsnake = {
              prompts.tailscale-client-id.persist = true;
              files.tailscale-client-id.neededFor = "activation";

              prompts.tailscale-client-secret.persist = true;
              files.tailscale-client-secret.neededFor = "activation";
            };
          };
        }
      ];

      boot.initrd.network.enable = true;
      boot.initrd.systemd.extraBin.ping = lib.getExe' pkgs.iputils "ping";

      # Run `ssh ${hostname}-unlock` then run `systemctl default`
      boot.initrd.systemd.services.hoopsnake = {
        unitConfig.DefaultDependencies = false;
      };

      boot.initrd.network.hoopsnake = {
        enable = true;
        systemd-credentials = {
          privateHostKey.file = config.clan.core.vars.generators.initrd-ssh.files.id_ed25519.path;
          privateHostKey.encrypted = false;

          clientId.file = config.clan.core.vars.generators.hoopsnake.files.tailscale-client-id.path;
          clientId.encrypted = false;
          clientSecret.file = config.clan.core.vars.generators.hoopsnake.files.tailscale-client-secret.path;
          clientSecret.encrypted = false;
        };
        ssh = {
          authorizedKeysFile = pkgs.writeText "authorized_keys" (
            lib.concatStringsSep "\n" config.users.users.root.openssh.authorizedKeys.keys
          );
        };
        tailscale = {
          name = "${config.networking.hostName}-unlock";
          tags = [ "tag:initrd" ];
        };
      };

      virtualisation.allVmVariants = {
        # initrd secrets not supported in VMs yet
        boot.initrd.network.hoopsnake.enable =
          assert !config.system.build ? vmWithVars;
          lib.mkForce false;

        boot.initrd.kernelModules = [
          # for debugging installation in vms
          "virtio_pci"
          "virtio_net"
        ];
      };
    };
}
