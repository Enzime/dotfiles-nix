{
  nixosModule = { ... }: {
    # GNOME runs Wayland by default
    services.xserver.desktopManager.gnome.enable = true;
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs.gnomeExtensions) appindicator clipboard-indicator;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        clock-format = "12h";
        clock-show-seconds = true;
        clock-show-weekday = true;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
        home = [ "<Super>e" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>t";
        command = "gnome-terminal";
        name = "Launch Terminal";
      };

      "org/gnome/shell" = {
        disabled-extensions = [ ];

        enabled-extensions = [
          "clipboard-indicator@tudmotu.com"
          "appindicatorsupport@rgcjonas.gmail.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
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
