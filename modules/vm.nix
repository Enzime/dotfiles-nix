{
  darwinModule = { options, hostname, lib, ... }:
    let inherit (lib) mkIf mkVMOverride;
    in mkIf (options ? virtualisation) {
      networking.hostName = mkVMOverride "${hostname}-vm";
    };

  nixosModule = { config, lib, user, ... }:
    let
      inherit (lib) mkIf mkVMOverride;
      # The `virtualisation.diskImage` option only exists when using `nixos-rebuild build-vm`
    in mkIf (config.virtualisation ? diskImage) {
      users.users.root.password = "apple";
      users.users.${user} = {
        password = "apple";
        initialPassword = mkVMOverride null;
      };

      # WORKAROUND: home-manager for `root` will attempt to GC unless it is disabled
      nix.settings.min-free = mkVMOverride 0;

      system.activationScripts.expire-password = mkVMOverride "";

      # WORKAROUND: Attempting to set `virtualisation.qemu` fails even inside of a `mkIf`
      #             as the option needs to exist unconditionally.
      virtualisation = if (config.virtualisation ? diskImage) then {
        qemu.options = [
          "-display gtk,grab-on-hover=true,gl=on"
          # Use a better fake GPU
          "-vga none -device virtio-vga-gl"
        ];
      } else
        { };

      zramSwap.enable = true;
      zramSwap.memoryPercent = 250;

      programs.sway.extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
    };

  # WORKAROUND: { osConfig ? { }, ... }: fails when using `home-manager build`
  hmModule = { inputs, pkgs, lib, ... }@args:
    let inherit (lib) hasAttrByPath mkIf mkVMOverride;
    in mkIf (hasAttrByPath [ "osConfig" "virtualisation" "diskImage" ] args) {
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
}
