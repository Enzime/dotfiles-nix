{
  imports = [ "graphical" "i18n" "ios" "mullvad" "pim" ];

  darwinModule = { pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) apparency; };
  };

  nixosModule = { user, pkgs, ... }: {
    services.resilio.enable = true;
    services.resilio.listeningPort = 44444;
    services.resilio.enableWebUI = true;
    services.resilio.httpListenAddr = "0.0.0.0";

    users.users.${user}.extraGroups = [ "rslsync" ];
  };

  hmModule = { config, pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) hostPlatform;
      inherit (lib) mkIf optionalAttrs;
    in {
      home.packages = builtins.attrValues ({
        inherit (pkgs) gramps;
      } // optionalAttrs (!hostPlatform.isLinux || !hostPlatform.isAarch64) {
        # Runs on everything except `aarch64-linux`
        inherit (pkgs) discord;
      } // optionalAttrs (hostPlatform.isLinux && hostPlatform.isx86_64) {
        inherit (pkgs) joplin-desktop signal-desktop;
      });

      xsession.windowManager.i3.config.startup =
        mkIf (hostPlatform.isLinux && hostPlatform.isx86_64) [{
          command = "signal-desktop";
          always = true;
        }];

      programs.firefox.profiles.personal.isDefault = true;
    };
}
