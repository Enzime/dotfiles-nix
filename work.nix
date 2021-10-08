{ pkgs, ... }:

{
  home.packages = builtins.attrValues {
    inherit (pkgs) awscli2 aws-vault mongodb-tools slack;
  };

  programs.vscode.extensions = [
    pkgs.vscode-extensions.ethansk.restore-terminals
    pkgs.vscode-extensions.editorconfig.editorconfig
    pkgs.vscode-extensions.rioj7.commandOnAllFiles
  ];

  programs.vscode.userSettings = {
    "restoreTerminals.keepExistingTerminalsOpen" = true;
    "commandOnAllFiles.commands"."Trailing Spaces: Delete" = {
      "command" = "trailing-spaces.deleteTrailingSpaces";
      "includeFileExtensions" = [ ".js" ".json" ];
    };
  };
}
