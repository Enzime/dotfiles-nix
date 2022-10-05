{
  imports = [ "contacts" "ios" ];

  hmModule = { config, pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) discord joplin-desktop signal-desktop;
    };

    xsession.windowManager.i3.config.startup = [
      { command = "signal-desktop"; always = true; }
    ];

    programs.firefox.profiles.work = {
      id = 1;
      inherit (config.programs.firefox.profiles.default) settings;
    };

    programs.firefox.extensions = [
      pkgs.firefox-addons.copy-selected-links
      pkgs.firefox-addons.ff2mpv
      pkgs.firefox-addons.hover-zoom-plus
      pkgs.firefox-addons.improve-youtube
      pkgs.firefox-addons.multi-account-containers
      pkgs.firefox-addons.old-reddit-redirect
      pkgs.firefox-addons.reddit-enhancement-suite
      pkgs.firefox-addons.redirector
      pkgs.firefox-addons.sponsorblock
      pkgs.firefox-addons.tetrio-plus
      pkgs.firefox-addons.translate-web-pages
      pkgs.firefox-addons.tree-style-tab
      pkgs.firefox-addons.tst-wheel-and-double
      pkgs.firefox-addons.web-archives
    ];

    # Disable tab bar when using vertical tabs
    programs.firefox.profiles.default.userChrome = ''
      #TabsToolbar { visibility: collapse !important; }
    '';
  };
}
