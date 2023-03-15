{
  imports = [ "docker" ];

  darwinModule = { user, config, pkgs, ... }: {
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
      inherit (pkgs) awscli2 aws-vault postman slack;
    };

    home.sessionVariables = {
      AWS_SDK_LOAD_CONFIG = 1;
    };

    programs.zsh.initExtra = ''
      function agenix {
          $(which -p agenix) $@ -i =(op read $OP_SSH_KEY_URL)
      }
    '';

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
