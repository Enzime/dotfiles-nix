{ pkgs, ... }:

{
  home.packages = builtins.attrValues {
     # Necessary for non-NixOS systems which won't have the flakiest version of Nix
    inherit (pkgs) nix;
  };
}
