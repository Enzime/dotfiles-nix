{
  imports = [ "personal" ];

  nixosModule = {
    programs.steam.enable = true;
  };

  homeModule =
    { pkgs, lib, ... }:
    {
      home.packages = builtins.attrValues (
        lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          inherit (pkgs) steam-bin;
        }
      );

      programs.lutris.enable = !pkgs.stdenv.hostPlatform.isDarwin;

      preservation = {
        directories = [
          ".steam"
          ".local/share/steam"
          (lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) ".local/share/lutris")
        ];
      };
    };
}
