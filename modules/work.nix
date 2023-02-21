{
  imports = [ "docker" ];

  darwinModule = { user, config, pkgs, ... }: {
    # WORKAROUND: Due to nix-darwin using ~/Applications exclusively
    # Slack can't be installed through home-manager currently.
    environment.systemPackages = assert (!config.home-manager.users.${user}.home.file ? "Applications/Home Manager Apps"); builtins.attrValues {
      inherit (pkgs) shortcat slack;
    };

    system.activationScripts.extraUserActivation.text = ''
      defaults write com.tinyspeck.slackmacgap SlackNoAutoUpdates -bool YES
    '';

    age.secrets.aws_config = {
      file = ../secrets/aws_config.age;
      path = "/Users/${user}/.aws/config";
      owner = user;
    };
  };

  hmModule = { pkgs, lib, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) awscli2 aws-vault slack;
    };

    programs.git.includes = [
      { condition = "gitdir:~/Work/"; path = "~/.config/git/config.work"; }
    ];

    programs.firefox.extensions = [
      pkgs.firefox-addons.multi-account-containers
    ];

    programs.vscode.extensions = [
      pkgs.vscode-extensions.graphql.vscode-graphql
    ];

    programs.vscode.userSettings = {
      "typescript.preferences.importModuleSpecifier" = "relative";
    };

    home.file.".aws/credentials".text = "";
  };
}
