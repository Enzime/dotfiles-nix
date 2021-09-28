{ pkgs, ... }:

{
  home.packages = builtins.attrValues {
    inherit (pkgs) aws-vault;
  };

  programs.vscode.extensions = [
    pkgs.vscode-extensions.ethansk.restore-terminals
    pkgs.vscode-extensions.editorconfig.editorconfig
  ];
}
