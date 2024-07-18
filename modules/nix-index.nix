{
  homeModule = { pkgs, lib, ... }:
    let
      inherit (lib) mkIf;
      inherit (pkgs.stdenv) hostPlatform;
    in (mkIf (!hostPlatform.isDarwin || !hostPlatform.isAarch64) {
      home.packages = builtins.attrValues { inherit (pkgs) comma; };

      programs.nix-index.enable = true;
    });
}
