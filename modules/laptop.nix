{
  imports = [ "wireless" ];

  nixosModule = { ... }: {
    services.xserver.libinput.enable = true;

    services.udev.extraHwdb = ''
      evdev:name:AT Translated Set 2 keyboard:dmi:*
        KEYBOARD_KEY_3a=esc
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
