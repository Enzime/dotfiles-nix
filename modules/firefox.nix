{
  hmModule = { pkgs, lib, ... }:
    let inherit (pkgs.stdenv) hostPlatform;
    in {
      home.activation.setDefaultBrowser = lib.mkIf hostPlatform.isDarwin
        (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if ! ${lib.getExe pkgs.defaultbrowser} firefox; then
            open ~/Applications/Home\ Manager\ Apps/Firefox.app
            ${lib.getExe pkgs.defaultbrowser} firefox
          fi
        '');

      programs.firefox.enable = true;
      programs.firefox.package = if hostPlatform.isDarwin then
        pkgs.firefox-bin-unwrapped
      else
        pkgs.firefox;
      programs.firefox.profiles.default = {
        isDefault = true;
        extensions = [
          pkgs.firefox-addons.onepassword-password-manager
          pkgs.firefox-addons.clearurls
          pkgs.firefox-addons.ublock-origin
          pkgs.firefox-addons.youtube-nonstop
        ];
        search = {
          default = "DuckDuckGo";
          engines = {
            "Google".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "Amazon.com.au".metaData.hidden = true;
            "eBay".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
          };
          force = true;
        };
        settings = {
          "browser.privatebrowsing.vpnpromourl" = "";
          "datareporting.healthreport.uploadEnabled" = false;
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "app.normandy.enabled" = false;

          "browser.aboutConfig.showWarning" = false;

          # Open previous windows and tabs
          "browser.startup.page" = 3;

          "browser.tabs.closeWindowWithLastTab" = false;
          # Warn when attempting to close a window with multiple tabs
          "browser.tabs.warnOnClose" = true;
          "signon.rememberSignons" = false;
          "dom.security.https_only_mode" = true;

          # Use userChrome.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };

      home.sessionVariablesExtra = ''
        if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
          export MOZ_ENABLE_WAYLAND=1
        fi
      '';
    };
}
