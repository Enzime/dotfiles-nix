{
  imports = [ "wireless" ];

  nixosModule = { pkgs, ... }: {
    services.xserver.libinput.enable = true;

    services.udev.extraHwdb = ''
      evdev:name:AT Translated Set 2 keyboard:dmi:*
        KEYBOARD_KEY_3a=esc
    '';

    # Add HandlePowerKeyLongPress when we're using systemd 250
    services.logind.extraConfig = assert (builtins.compareVersions pkgs.systemd.version "250" == -1); ''
      HandlePowerKey=ignore
    '';
  };

  hmModule = { lib, ... }: {
    dconf.settings = {
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = false;
        tap-to-click = true;
      };
    };

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
