let
  shared =
    { keys, ... }:
    {
      nix.settings.substituters = [
        "https://enzime.cachix.org"
        "https://cache.clan.lol"
      ];
      nix.settings.trusted-public-keys = builtins.attrValues (
        {
          inherit (keys.signing) aether chi-linux-builder echo;

          "enzime.cachix.org" = keys.signing."enzime.cachix.org";
        }
        // keys.signing.clan
      );
    };
in
{
  nixosModule = shared;

  darwinModule = shared;

  homeModule =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues { inherit (pkgs) cachix; };
    };
}
