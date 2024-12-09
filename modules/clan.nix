{
  nixosModule = { options, inputs, host, hostname, pkgs, lib, ... }: {
    config = lib.optionalAttrs (options ? clan) {
      clan.core.networking.targetHost = "root@${host}";
    };
  };
}
