{
  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) docker-client;
    };

    virtualisation.podman.enable = true;

    # Necessary for `arion`
    virtualisation.podman.dockerSocket.enable = true;
    virtualisation.podman.defaultNetwork.dnsname.enable = true;

    users.users.${user}.extraGroups = [ "podman" ];
  };
}
