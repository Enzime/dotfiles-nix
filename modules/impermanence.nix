{
  homeModule = { config, pkgs, lib, ... }:
    let inherit (lib) mkIf;
    in {
      programs.vscode.mutableExtensionsDir =
        mkIf config.programs.vscode.enable false;
    };
}
