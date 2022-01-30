{
  hmModule = { pkgs, ... }: {
    programs.firefox.enable = true;
    programs.firefox.extensions = [
      pkgs.firefox-addons.onepassword-password-manager
      pkgs.firefox-addons.clearurls
      pkgs.firefox-addons.ublock-origin
      pkgs.firefox-addons.youtube-nonstop
    ];
    programs.firefox.profiles.default = {
      isDefault = true;
      settings = {
        "browser.privatebrowsing.vpnpromourl" = "";
        "datareporting.healthreport.uploadEnabled" = false;
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "app.normandy.enabled" = false;

        "browser.aboutConfig.showWarning" = false;

        "browser.tabs.closeWindowWithLastTab" = false;
        # Warn when attempting to close a window with multiple tabs
        "browser.tabs.warnOnClose" = true;
        "signon.rememberSignons" = false;
        "dom.security.https_only_mode" = true;
      };
    };

    programs.zsh.profileExtra = ''
      if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
        export MOZ_ENABLE_WAYLAND=1
      fi
    '';
  };
}
