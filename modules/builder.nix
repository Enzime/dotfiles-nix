let
  shared = { keys, pkgs, ... }: {
    users.users.builder = {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = builtins.attrValues {
        inherit (keys.users) enzime;
        inherit (keys.hosts) sigma;
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

  darwinModule = { ... }: {
    imports = [ shared ];

    users.knownUsers = [ "builder" ];

    users.users.builder.uid = 550;
    users.users.builder.home = "/Users/builder";
  };
}
