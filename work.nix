{ pkgs, ... }:

{
  home.packages = builtins.attrValues {
    inherit (pkgs) aws-vault;
  };
}
