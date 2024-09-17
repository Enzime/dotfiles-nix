let
  shared = { inputs, keys, pkgs, lib, ... }: {
    nix.settings.substituters = [ "https://enzime.cachix.org" ];
    nix.settings.trusted-public-keys = builtins.attrValues {
      inherit (keys.signing) aether chi-linux-builder echo;

      "enzime.cachix.org" = keys.signing."enzime.cachix.org";
    };

    users.users.builder = {
      # Still overridable with mkForce
      shell = lib.mkOverride 75 pkgs.zsh;
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

  homeModule = { pkgs, ... }: {
    home.packages = builtins.attrValues { inherit (pkgs) cachix; };
  };
}
