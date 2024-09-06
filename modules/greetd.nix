{
  nixosModule = { config, pkgs, lib, ... }: {
    services.greetd.enable = true;
    programs.regreet.enable = true;

    programs.regreet.font.name = "DejaVu Sans";
    programs.regreet.font.size = 12;
    programs.regreet.font.package = pkgs.dejavu_fonts;

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
