{
  imports = [ "wireless" ];

  nixosModule = { user, pkgs, ... }: {
    services.xserver.libinput.enable = true;

    services.udev.extraHwdb = ''
      evdev:name:AT Translated Set 2 keyboard:dmi:*
        KEYBOARD_KEY_3a=esc
    '';

    services.logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    programs.light.enable = true;
    users.users.${user}.extraGroups = [ "video" ];
  };

  hmModule = { pkgs, lib, ... }: let
    keybindings = {
      "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
      "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
    };
  in {
    dconf.settings = {
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = false;
        tap-to-click = true;
      };
    };

    wayland.windowManager.sway.config.input = {
      "type:touchpad" = {
        tap = "enabled";
      };
    };

    xsession.windowManager.i3.config.keybindings = keybindings;
    wayland.windowManager.sway.config.keybindings = keybindings;

    services.polybar.config = {
      "bar/base" = {
        modules-right = lib.mkForce "dotfiles battery wireless ethernet fs memory date";
      };

      "module/battery" = {
        type = "internal/battery";
        full-at = 98;

        time-format = "%H:%M";

        label-discharging = "DIS %percentage%% %time% remaining";
        label-charging = "CHG %percentage%% %time% till full";
        label-full = "BAT FULL 100%";
      };
    };
  };
}
