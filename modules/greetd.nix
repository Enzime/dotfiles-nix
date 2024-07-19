{
  nixosModule = { config, pkgs, lib, ... }: {
    # Remove this when the programs.regreet.theme options get added
    # so we no longer need to add these packages manually
    environment.systemPackages = assert !config.programs.regreet ? theme;
      builtins.attrValues {
        inherit (pkgs) gnome-themes-extra;
        inherit (pkgs.gnome) adwaita-icon-theme;
      };

    services.greetd.enable = true;
    programs.regreet.enable = true;
    programs.regreet.settings.font_name = "DejaVu Sans 16";

    services.greetd.settings.default_session.command =
      "${lib.getExe' pkgs.dbus "dbus-run-session"} ${
        lib.getExe pkgs.sway
      } --config ${
        pkgs.writeText "greetd-sway-config" ''
          exec "${lib.getExe pkgs.wayvnc} &"
          exec "${lib.getExe pkgs.greetd.regreet}; swaymsg exit"

          include /etc/sway/config.d/*
        ''
      }";

    users.users.greeter.home = "/var/greeter";
    users.users.greeter.createHome = true;

    home-manager.users.greeter = {
      # As we don't open the firewall, it should only be accessible over Tailscale
      xdg.configFile."wayvnc/config".text = ''
        address=0.0.0.0
      '';

      home.stateVersion = "24.11";
    };
  };
}
