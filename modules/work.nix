{
  darwinModule = { user, config, pkgs, ... }: {
    # WORKAROUND: Due to nix-darwin using ~/Applications exclusively
    # Slack can't be installed through home-manager currently.
    environment.systemPackages = assert (!config.home-manager.users.${user}.home.file ? "Applications/Home Manager Apps"); builtins.attrValues {
      inherit (pkgs) slack;
    };

    system.activationScripts.extraUserActivation.text = ''
      defaults write com.tinyspeck.slackmacgap SlackNoAutoUpdates -bool YES
    '';
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) slack;
    };
  };
}
