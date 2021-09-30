{ pkgs, ... }:

{
  home.packages = builtins.attrValues {
    inherit (pkgs) awscli2 aws-vault mongodb-tools;
  };

  programs.vscode.extensions = [
    pkgs.vscode-extensions.ethansk.restore-terminals
    pkgs.vscode-extensions.editorconfig.editorconfig
  ];
}
