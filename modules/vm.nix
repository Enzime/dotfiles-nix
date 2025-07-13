{
  darwinModule = { options, hostname, lib, ... }:
    let inherit (lib) mkIf mkVMOverride;
    in mkIf (options ? virtualisation) {
      networking.hostName = mkVMOverride "${hostname}-vm";
    };

  nixosModule = { config, pkgs, lib, ... }: {
    options.virtualisation.allVmVariants =
      lib.mkOption { type = lib.types.deferredModule; };

    config = {
      virtualisation.allVmVariants = { user, config, ... }: {
        # Prevent module from getting imported twice when using `nixosConfigurations.<host>.config.on.<system>.system.build.vmWithDisko`
        # which leads to QEMU options being repeated
        key = "vm#allVmVariants";

        home-manager.sharedModules = [
          ({ lib, ... }: {
            services.polybar.config."bar/centre".monitor =
              lib.mkVMOverride "Virtual-1";

            xsession.windowManager.i3.config.workspaceOutputAssign =
              lib.mkVMOverride [{
                workspace = "101";
                output = "Virtual-1";
              }];

            wayland.windowManager.sway.config.workspaceOutputAssign =
              lib.mkVMOverride [{
                workspace = "1";
                output = "Virtual-1";
              }];

            systemd.user.services.swayidle = lib.mkVMOverride { };

            wayland.windowManager.sway.config.output = {
              Virtual-1 = { scale = "2"; };
            };
          })
        ];

        users.users.root = {
          password = "apple";
          hashedPasswordFile = lib.mkForce null;
        };

        users.users.${user} = {
          password = "apple";
          hashedPasswordFile = lib.mkForce null;
        };

        # WORKAROUND: home-manager for `root` will attempt to GC unless it is disabled
        nix.settings.min-free = 0;

        virtualisation.qemu = let pkgs' = config.virtualisation.host.pkgs;
        in {
          options = lib.mkIf pkgs'.stdenv.hostPlatform.isLinux [
            "-display gtk,grab-on-hover=true,gl=on"
            # Use a better fake GPU
            (lib.mkIf pkgs'.stdenv.hostPlatform.isx86_64
              "-vga none -device virtio-vga-gl")
          ];

          networkingOptions = lib.mkIf pkgs'.stdenv.hostPlatform.isDarwin
            (lib.mkForce [
              "-device virtio-net-pci,netdev=user.0"
              ''-netdev vmnet-shared,id=user.0,"$QEMU_NET_OPTS"''
            ]);
        };

        services.tailscale.authKeyFile = lib.mkForce null;

        zramSwap.enable = true;
        zramSwap.memoryPercent = 250;

        programs.sway.extraSessionCommands = ''
          export WLR_NO_HARDWARE_CURSORS=1
        '';

        facter.report =
          lib.mkOptionDefault { virtualisation = lib.mkForce "qemu"; };
      };

      virtualisation.vmVariant = config.virtualisation.allVmVariants;

      virtualisation.vmVariantWithBootLoader =
        config.virtualisation.allVmVariants;

      virtualisation.vmVariantWithDisko = {
        imports = [ config.virtualisation.allVmVariants ];

        virtualisation.fileSystems = lib.mkIf config.preservation.enable {
          "/persist".neededForBoot = true;
        };
      };
    };

  };
}
