{
  nixosModule = { config, lib, user, ... }: let
    inherit (lib) mkIf mkVMOverride;
  # The `virtualisation.diskImage` option only exists when using `nixos-rebuild build-vm`
  in mkIf (config.virtualisation ? diskImage) {
    networking.interfaces = mkVMOverride { };

    users.users.root.password = "apple";
    users.users.${user}.password = "apple";

    # WORKAROUND: Attempting to set `virtualisation.qemu` fails even inside of a `mkIf`
    #             as the option needs to exist unconditionally.
    virtualisation = if (config.virtualisation ? diskImage) then {
      qemu.options = [
        "-display gtk,grab-on-hover=true,gl=on"
        # Use a better fake GPU
        "-vga none -device virtio-vga-gl"
      ];
    } else { };

    programs.sway.extraSessionCommands = ''
      export WLR_NO_HARDWARE_CURSORS=1
    '';

    services.xserver.displayManager.defaultSession = mkIf config.programs.sway.enable (mkVMOverride "sway");
  };

  # WORKAROUND: { osConfig ? { }, ... }: fails when using `home-manager build`
  hmModule = { lib, ... }@args: let
    inherit (lib) hasAttrByPath mkIf mkVMOverride;
  in mkIf (hasAttrByPath [ "osConfig" "virtualisation" "diskImage" ] args) {
    home.file.".zshrc.secrets".text = "";

    services.polybar.config."bar/centre".monitor = mkVMOverride "Virtual-1";

    xsession.windowManager.i3.config.startup = mkVMOverride [
      { command = "systemctl --user restart polybar"; always = true; notification = false; }
    ];

    xsession.windowManager.i3.config.workspaceOutputAssign = mkVMOverride [
      { workspace = "101"; output = "Virtual-1"; }
    ];

    wayland.windowManager.sway.config.workspaceOutputAssign = mkVMOverride [
      { workspace = "1"; output = "Virtual-1"; }
    ];
  };
}
