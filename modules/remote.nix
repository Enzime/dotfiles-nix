let
  shared = { inputs, keys, pkgs, ... }: {
    nix.settings.substituters =
      inputs.self.outputs.nixConfig.extra-substituters;
    nix.settings.trusted-public-keys =
      inputs.self.outputs.nixConfig.extra-trusted-public-keys;

    users.users.builder = {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = builtins.attrValues {
        inherit (keys.users) enzime;
        inherit (keys.hosts) hermes-nixos sigma;
      };
    };
  };
in {
  nixosModule = { ... }: {
    imports = [ shared ];

    users.groups.builder = { };

    users.users.builder.isNormalUser = true;
    users.users.builder.group = "builder";
  };

  darwinModule = { config, pkgs, ... }: {
    imports = [ shared ];

    users.knownUsers = [ "builder" ];

    users.users.builder.uid = 550;
    users.users.builder.home = "/Users/builder";
  };

  hmModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) cachix; };
  };
}
