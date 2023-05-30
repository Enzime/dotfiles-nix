{
  nixosModule = { inputs, ... }: {
    nix.settings.substituters =
      inputs.self.outputs.nixConfig.extra-substituters;
    nix.settings.trusted-public-keys =
      inputs.self.outputs.nixConfig.extra-trusted-public-keys;
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) cachix; };
  };
}
