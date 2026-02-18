{
  homeModule =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues { inherit (pkgs) deluge; };
    };
}
