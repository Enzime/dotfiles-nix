{
  imports = [ "graphical" "i18n" "ios" "pim" ];

  nixosModule = { user, pkgs, ... }: {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;

    services.resilio.enable = true;
    services.resilio.listeningPort = 44444;
    services.resilio.enableWebUI = true;
    services.resilio.httpListenAddr = "0.0.0.0";

    users.users.${user}.extraGroups = [ "rslsync" ];
  };

  hmModule = { config, pkgs, lib, ... }: {
    home.packages = builtins.attrValues ({
      inherit (pkgs) discord gramps;
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      inherit (pkgs) joplin-desktop signal-desktop;
    });

    xsession.windowManager.i3.config.startup = [{
      command = "signal-desktop";
      always = true;
    }];

    programs.firefox.profiles.personal.isDefault = true;
  };
}
