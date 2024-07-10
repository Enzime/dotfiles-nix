{
  imports = [ "wireless" ];

  nixosModule = { user, pkgs, lib, ... }: {
    time.timeZone = lib.mkForce null;
    services.automatic-timezoned.enable = true;
    services.geoclue2.enableDemoAgent = lib.mkForce true;

    services.libinput.enable = true;

    services.udev.extraHwdb = ''
      evdev:name:AT Translated Set 2 keyboard:dmi:*
        KEYBOARD_KEY_3a=esc
    '';

    services.logind.extraConfig = ''
      HandlePowerKey=lock
      HandleLidSwitch=suspend-then-hibernate
      HandleLidSwitchExternalPower=lock
    '';

    systemd.sleep.extraConfig = ''
      HibernateDelaySec=5m
    '';

    programs.light.enable = true;
    users.users.${user}.extraGroups = [ "video" ];

    programs.captive-browser.enable = true;
  };

  darwinModule = { pkgs, lib, ... }: {
    time.timeZone = lib.mkForce null;

    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) aldente; };

    launchd.user.agents.alDente = {
      serviceConfig.ProgramArguments =
        [ "/Applications/Nix Apps/AlDente.app/Contents/MacOS/AlDente" ];
      serviceConfig.RunAtLoad = true;
    };

    system.defaults.trackpad.Clicking = true;

    # WORKAROUND: Setting this via `system.defaults` won't check the checkbox
    #             in System Preferences > Trackpad
    system.activationScripts.extraUserActivation.text = ''
      defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    '';

    security.pam.enableSudoTouchIdAuth = true;

    # WORKAROUND: Using Override Local DNS with tailscaled on macOS leads to
    # DNS not working for a long time after reconnecting to the internet.
    services.tailscale.overrideLocalDns = false;

    networking.dns = [ "1.1.1.1" ];
  };

  hmModule = { pkgs, lib, ... }:
    let
      inherit (lib) mkIf;
      inherit (pkgs.stdenv) hostPlatform;

      keybindings = {
        "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.light} -U 10";
        "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.light} -A 10";
      };
    in mkIf hostPlatform.isLinux {
      wayland.windowManager.sway.config.input = {
        "type:touchpad" = { tap = "enabled"; };
      };

      xsession.windowManager.i3.config.keybindings = keybindings;
      wayland.windowManager.sway.config.keybindings = keybindings;

      services.polybar.config = {
        "bar/base" = {
          modules-right =
            lib.mkForce "dotfiles battery wireless ethernet fs memory date";
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
