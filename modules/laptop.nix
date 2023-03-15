{
  imports = [ "wireless" ];

  nixosModule = { user, pkgs, ... }: {
    services.xserver.libinput.enable = true;

    services.udev.extraHwdb = ''
      evdev:name:AT Translated Set 2 keyboard:dmi:*
        KEYBOARD_KEY_3a=esc
    '';

    services.logind.extraConfig = ''
      HandlePowerKey=lock
    '';

    programs.light.enable = true;
    users.users.${user}.extraGroups = [ "video" ];
  };

  darwinModule = { ... }: {
    system.defaults.trackpad.Clicking = true;

    # WORKAROUND: Setting this via `system.defaults` won't check the checkbox
    #             in System Preferences > Trackpad
    system.activationScripts.extraUserActivation.text = ''
      defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    '';

    security.pam.enableSudoTouchIdAuth = true;
  };

  hmModule = { pkgs, lib, ... }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv) hostPlatform;

    keybindings = {
      "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
      "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
    };
  in mkIf hostPlatform.isLinux {
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
