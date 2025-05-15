{
  homeModule = { config, pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) hostPlatform;

      cfg = config.programs.firefox;
    in {
      home.activation.setDefaultBrowser =
        lib.mkIf (cfg.enable && hostPlatform.isDarwin)
        (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if ! ${lib.getExe pkgs.defaultbrowser} firefox; then
            /usr/bin/open ${pkgs.firefox-bin}/Applications/Firefox.app
            ${lib.getExe pkgs.defaultbrowser} firefox
          fi
        '');

      programs.firefox.enable = lib.mkDefault true;
      programs.firefox.package =
        if hostPlatform.isDarwin then pkgs.firefox-bin else pkgs.firefox;
      programs.firefox.profiles.base = {
        id = 0;

        extensions.packages = [
          pkgs.firefox-addons.onepassword-password-manager
          pkgs.firefox-addons.clearurls
          pkgs.firefox-addons.ublock-origin
          pkgs.firefox-addons.youtube-nonstop
          pkgs.firefox-addons.kagi-privacy-pass
        ];

        search = {
          default = "kagi";
          engines = {
            kagi = {
              name = "Kagi";
              urls =
                [{ template = "https://kagi.com/search?q={searchTerms}"; }];
              icon = "https://kagi.com/favicon.ico";
            };

            google.metaData.hidden = true;
            wikipedia.metaData.hidden = true;
            bing.metaData.hidden = true;
            amazondotcom-au.metaData.hidden = true;
            ebay.metaData.hidden = true;
            amazondotcom-us.metaData.hidden = true;
          };
          force = true;
        };

        settings = {
          "browser.privatebrowsing.vpnpromourl" = "";
          "datareporting.healthreport.uploadEnabled" = false;
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "app.normandy.enabled" = false;
          "signon.firefoxRelay.feature" = "disabled";

          "browser.aboutConfig.showWarning" = false;

          # Open previous windows and tabs
          "browser.startup.page" = 3;

          "browser.tabs.closeWindowWithLastTab" = false;
          # Warn when attempting to close a window with multiple tabs
          "browser.tabs.warnOnClose" = true;
          "signon.rememberSignons" = false;
          "dom.security.https_only_mode" = true;

          "extensions.update.enabled" = false;

          # Use userChrome.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # Default to light mode on all websites
          "layout.css.prefers-color-scheme.content-override" = 1;
        };
      };

      home.sessionVariablesExtra = ''
        if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
          export MOZ_ENABLE_WAYLAND=1
        fi
      '';

      home.persistence."/persist${config.home.homeDirectory}".directories =
        map (name: ".mozilla/firefox/${name}")
        (builtins.attrNames cfg.profiles);
    };
}
