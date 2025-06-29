let
  shared = {
    programs._1password-gui.enable = true;
    programs._1password.enable = true;
  };
in {
  imports = [ "graphical-minimal" "mpv" ];

  darwinModule = { pkgs, lib, ... }: {
    imports = [ shared ];

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) alt-tab-macos raycast utm zed-editor;
    };

    launchd.user.agents.raycast = {
      command = ''"/Applications/Nix Apps/Raycast.app/Contents/MacOS/Raycast"'';
      serviceConfig.RunAtLoad = true;
    };

    services.karabiner-elements.enable = true;

    launchd.user.agents.alt-tab = {
      command = ''"/Applications/Nix Apps/AltTab.app/Contents/MacOS/AltTab"'';
      serviceConfig.RunAtLoad = true;
    };

    system.defaults.CustomUserPreferences."com.lwouis.alt-tab-macos" = {
      SUAutomaticallyUpdate = false;
      SUEnableAutomaticChecks = false;
      updatePolicy = 0;

      alignThumbnails = true;
      # Took a lot of debugging to figure this out
      # plutil -type hideSpaceNumberLabels ~/Library/Preferences/com.lwouis.alt-tab-macos.plist
      hideSpaceNumberLabels = "true";
      # Only show windows from current space
      spacesToShow = 1;
      hideWindowlessApps = "true";
      holdShortcut = "\\u2318";
      startAtLogin = "false";

      blacklist = lib.generators.toJSON { } [
        {
          "bundleIdentifier" = "com.apple.finder";
          "hide" = "2";
          "ignore" = "0";
        }
        {
          "bundleIdentifier" = "com.apple.ScreenSharing";
          "hide" = "0";
          "ignore" = "2";
        }
        {
          "bundleIdentifier" = "com.utmapp.UTM";
          "hide" = "0";
          "ignore" = "2";
        }
        {
          "bundleIdentifier" = "com.apple.Terminal";
          "hide" = "2";
          "ignore" = "0";
        }
      ];
    };
  };

  nixosModule = { user, pkgs, lib, ... }: {
    imports = [ shared ];

    environment.systemPackages = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64
      (builtins.attrValues { inherit (pkgs) spotify-tray; });

    programs._1password-gui.polkitPolicyOwners = [ user ];
  };

  homeModule = { config, pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) hostPlatform;
      inherit (lib) optionalAttrs;
    in {
      home.packages = builtins.attrValues ({
        inherit (pkgs) qalculate-gtk remmina signal-desktop-bin;
      } // optionalAttrs (!hostPlatform.isLinux || !hostPlatform.isAarch64) {
        # Works on every platform except `aarch64-linux`
        # Spotify is only necessary for the icons on Linux
        inherit (pkgs) spotify;
      });

      home.activation.disableSpotifyUpdates = lib.mkIf hostPlatform.isDarwin
        (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          SPOTIFY_UPDATE_DIR=~/Library/Application\ Support/Spotify/PersistentCache/Update
          if ! /usr/bin/stat -f "%Sf" "$SPOTIFY_UPDATE_DIR" 2> /dev/null | grep -q uchg; then
            rm -rf "$SPOTIFY_UPDATE_DIR"
            mkdir -p "$SPOTIFY_UPDATE_DIR"
            /usr/bin/chflags uchg "$SPOTIFY_UPDATE_DIR"
          fi
        '');

      home.persistence."/persist${config.home.homeDirectory}" = {
        directories = [ ".config/1Password" ];
      };

      programs.ghostty.enable = true;

      programs.vscode.package = pkgs.vscode;

      home.file.".ssh/config".text = let
        _1password-agent = if hostPlatform.isDarwin then
          "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        else
          "~/.1password/agent.sock";
      in ''
        Match host * exec "test -z $SSH_CONNECTION"
          IdentityAgent "${_1password-agent}"
          ForwardAgent yes

        Host *
          ServerAliveInterval 120
      '';

      programs.firefox.profiles.base.isDefault = false;

      programs.firefox.profiles.personal = {
        id = 1;

        inherit (config.programs.firefox.profiles.base) settings;

        search = {
          inherit (config.programs.firefox.profiles.base.search)
            default engines force;
        };

        extensions.packages =
          config.programs.firefox.profiles.base.extensions.packages ++ [
            pkgs.firefox-addons.copy-selected-links
            pkgs.firefox-addons.ff2mpv
            pkgs.firefox-addons.hover-zoom-plus
            pkgs.firefox-addons.improved-tube
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
        userChrome = ''
          #TabsToolbar { visibility: collapse !important; }
        '';
      };

      programs.firefox.profiles.work = {
        id = 2;

        inherit (config.programs.firefox.profiles.base) settings;

        search = {
          inherit (config.programs.firefox.profiles.base.search)
            default engines force;
        };

        extensions.packages =
          config.programs.firefox.profiles.base.extensions.packages ++ [
            pkgs.firefox-addons.multi-account-containers
            pkgs.firefox-addons.open-url-in-container
          ];
      };
    };
}
