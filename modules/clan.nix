let
  shared = { options, hostname, lib, ... }: {
    config = lib.optionalAttrs (options ? clan) {
      clan.core.networking.targetHost = "root@${hostname}";
    };
  };
in {
  nixosModule = shared;

  darwinModule = shared;

  homeModule = {
    home.file.".ssh/config".text = ''
      Host build01
        ProxyJump tunnel@clan.lol
        Hostname fda9:b487:2919:3547:3699:9336:90ec:cb59

      Host build02
        Hostname build02.tailfc885e.ts.net
        User admin

      Host storinator01
        ProxyJump tunnel@clan.lol
        Hostname fda9:b487:2919:3547:3699:9393:7f57:6e6b
    '';
  };
}
