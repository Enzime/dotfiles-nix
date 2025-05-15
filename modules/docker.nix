{
  darwinModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) colima docker-client docker-compose;
    };
  };

  nixosModule = { pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      # Uses podman-compose instead of docker-compose
      inherit (pkgs) arion;
    };

    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
  };
}
