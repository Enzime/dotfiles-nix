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

  hmModule = { pkgs, lib, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) awscli2 aws-vault slack;
    };

    programs.git.includes = [
      { condition = "gitdir:~/Work/"; path = "~/.config/git/config.work"; }
    ];

    programs.vscode.extensions = [
      pkgs.vscode-extensions.graphql.vscode-graphql
    ];
  };
}
