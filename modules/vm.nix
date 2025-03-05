let
  homeModule = { inputs, pkgs, lib, ... }:
    let inherit (lib) mkVMOverride;
    in {
      services.polybar.config."bar/centre".monitor = mkVMOverride "Virtual-1";

      xsession.windowManager.i3.config.workspaceOutputAssign = mkVMOverride [{
        workspace = "101";
        output = "Virtual-1";
      }];

      wayland.windowManager.sway.config.workspaceOutputAssign = mkVMOverride [{
        workspace = "1";
        output = "Virtual-1";
      }];

      systemd.user.services.swayidle = mkVMOverride { };

      wayland.windowManager.sway.config.output = {
        Virtual-1 = { scale = "2"; };
      };
    };
in {
  darwinModule = { options, hostname, lib, ... }:
    let inherit (lib) mkIf mkVMOverride;
    in mkIf (options ? virtualisation) {
      networking.hostName = mkVMOverride "${hostname}-vm";
    };

  nixosModule = { config, user, pkgs, lib, ... }:
    let
      inherit (lib) mkForce mkVMOverride;

      shared = {
        home-manager.sharedModules = [ homeModule ];

        users.users.root.password = "apple";
        users.users.${user} = {
          password = mkVMOverride "apple";
          initialPassword = mkForce null;
          hashedPasswordFile = mkForce null;
        };

        # WORKAROUND: home-manager for `root` will attempt to GC unless it is disabled
        nix.settings.min-free = 0;

        system.activationScripts.expire-password = mkForce "";

        virtualisation.qemu.options = [
          "-display gtk,grab-on-hover=true,gl=on"
          # Use a better fake GPU
          (lib.mkIf pkgs.stdenv.hostPlatform.isx86_64
            "-vga none -device virtio-vga-gl")
        ];

        zramSwap.enable = true;
        zramSwap.memoryPercent = 250;

        programs.sway.extraSessionCommands = ''
          export WLR_NO_HARDWARE_CURSORS=1
        '';
      };
    in {
      virtualisation.vmVariant = shared;

      virtualisation.vmVariantWithDisko = {
        imports = [ shared ];

        disko.testMode = true;

        virtualisation.fileSystems =
          lib.mkIf config.environment.persistence."/persist".enable {
            "/persist".neededForBoot = true;
          };
      };
    };
}
