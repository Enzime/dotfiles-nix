{
  nixosModule = { options, inputs, host, hostname, pkgs, lib, ... }: {
    config = lib.optionalAttrs (options ? clan) {
      clan.core.networking.targetHost = "root@${host}";
    };
  };

  homeModule = { ... }: {
    home.file.".ssh/config".text = ''
      Host build02
        Hostname build02.tailfc885e.ts.net
        User admin

      Host storinator01
        ProxyJump tunnel@clan.lol
        Hostname fda9:b487:2919:3547:3699:9393:7f57:6e6b
    '';
  };
}
