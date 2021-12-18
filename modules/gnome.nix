{
  imports = [ "graphical" ];

  nixosModule = { ... }: {
    # GNOME runs Wayland by default
    services.xserver.desktopManager.gnome.enable = true;
  };

  hmModule = { pkgs, lib, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) firefox-wayland;
      inherit (pkgs.gnomeExtensions) appindicator clipboard-indicator;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        clock-format = "12h";
        clock-show-seconds = true;
        clock-show-weekday = true;
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
        night-light-temperature = lib.hm.gvariant.mkUint32 3500;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        home = [ "<Shift><Super>e" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>t";
        command = "gnome-terminal";
        name = "Launch Terminal";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super>e";
        command = "gtk-launch ranger.desktop";
        name = "Launch Ranger";
      };

      "org/gnome/shell" = {
        disabled-extensions = [ ];

        enabled-extensions = [
          "drive-menu@gnome-shell-extensions.gcampax.github.com"

          "appindicatorsupport@rgcjonas.gmail.com"
          "clipboard-indicator@tudmotu.com"
        ];
      };

      "org/gnome/shell/overrides" = { };

      "org/gnome/terminal/legacy" = {
        theme-variant = "dark";
      };

      "org/gtk/settings/file-chooser" = {
        clock-format = "12h";
      };
    };
  };
}
