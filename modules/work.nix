{
  nixosModule = { user, ... }: {
    age.secrets.aws_config = {
      file = ../secrets/aws_config.age;
      path = "/home/${user}/.aws/config";
      owner = user;
    };

    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues {
      inherit (pkgs) awscli2 aws-vault mongodb-tools postman slack;
      inherit (pkgs.gnome) zenity;
    };

    programs.zsh.initExtra = ''
      export AWS_VAULT_PROMPT="zenity"
    '';

    programs.firefox.extensions = [
      pkgs.firefox-addons.react-devtools
      pkgs.firefox-addons.reduxdevtools
    ];

    programs.vscode.extensions = [
      pkgs.vscode-extensions.ethansk.restore-terminals
      pkgs.vscode-extensions.rioj7.commandOnAllFiles
      pkgs.vscode-extensions.octref.vetur
    ];

    programs.vscode.userSettings = {
      "restoreTerminals.keepExistingTerminalsOpen" = true;
      "commandOnAllFiles.commands"."Trailing Spaces: Delete" = {
        "command" = "trailing-spaces.deleteTrailingSpaces";
        "includeFileExtensions" = [ ".js" ".json" ];
      };
    };
  };
}
