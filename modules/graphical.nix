{
  imports = [ "graphical-minimal" "greetd" "mpv" ];

  darwinModule = { pkgs, lib, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) raycast utm; };

    launchd.user.agents.raycast = {
      serviceConfig.ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          /bin/wait4path /nix/store &amp;&amp; exec "/Applications/Nix Apps/Raycast.app/Contents/MacOS/Raycast"''
      ];
      serviceConfig.RunAtLoad = true;
    };

    system.activationScripts.extraActivation.text = ''
      mkdir -p /usr/local/bin
      cp ${lib.getExe pkgs._1password} /usr/local/bin/op
    '';

    services.karabiner-elements.enable = true;
  };

  nixosModule = { user, pkgs, lib, ... }: {
    environment.systemPackages = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64
      (builtins.attrValues { inherit (pkgs) spotify-tray; });

    programs._1password-gui.enable = true;
    programs._1password-gui.polkitPolicyOwners = [ user ];

    programs._1password.enable = true;
  };

  homeModule = { config, pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) hostPlatform;
      inherit (lib) optionalAttrs;
    in {
      home.packages = builtins.attrValues ({
        inherit (pkgs) qalculate-gtk remmina;
      } // optionalAttrs (!hostPlatform.isLinux || !hostPlatform.isAarch64) {
        # Works on every platform except `aarch64-linux`
        # Spotify is only necessary for the icons on Linux
        inherit (pkgs) spotify;
      });

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

        inherit (config.programs.firefox.profiles.base) search settings;

        extensions = config.programs.firefox.profiles.base.extensions ++ [
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

        inherit (config.programs.firefox.profiles.base) search settings;

        extensions = config.programs.firefox.profiles.base.extensions ++ [
          pkgs.firefox-addons.multi-account-containers
          pkgs.firefox-addons.open-url-in-container
        ];
      };
    };
}
