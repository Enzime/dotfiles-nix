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

      # WORKAROUND: virtio-vga-gl provides OpenGL 3.0 however OpenGL 3.3 is required for kitty
      programs.kitty.package = pkgs.writeShellScriptBin "kitty" ''
        LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty} "$@"
      '';

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

  nixosModule = { user, lib, ... }:
    let inherit (lib) mkVMOverride;
    in {
      virtualisation.vmVariant = {
        home-manager.sharedModules = [ homeModule ];

        users.users.root.password = "apple";
        users.users.${user} = {
          password = "apple";
          initialPassword = mkVMOverride null;
        };

        # WORKAROUND: home-manager for `root` will attempt to GC unless it is disabled
        nix.settings.min-free = 0;

        system.activationScripts.expire-password = mkVMOverride "";

        virtualisation.qemu.options = [
          "-display gtk,grab-on-hover=true,gl=on"
          # Use a better fake GPU
          "-vga none -device virtio-vga-gl"
        ];

        zramSwap.enable = true;
        zramSwap.memoryPercent = 250;

        programs.sway.extraSessionCommands = ''
          export WLR_NO_HARDWARE_CURSORS=1
        '';
      };
    };
}
