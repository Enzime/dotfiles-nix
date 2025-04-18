{
  nixosModule = { options, config, inputs, host, hostname, pkgs, lib, ... }: {
    config = lib.optionalAttrs (options ? clan) {
      clan.core.networking.targetHost = "root@${host}";

      clan.core.vars.generators.nix-signing-key = {
        files."key" = { };
        files."key.pub".secret = false;
        runtimeInputs = [
          config.nix.package
        ];
        script = ''
          nix key generate-secret --key-name ${config.networking.hostName}-1 > $out/key
          nix key convert-secret-to-public < $out/key > $out/key.pub
        '';
      };
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
