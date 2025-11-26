let
  shared = { options, config, hostname, keys, pkgs, lib, ... }: {
    imports = [{
      config = lib.optionalAttrs (options ? clan) {
        clan.core.networking.targetHost = "root@${hostname}";

        clan.core.vars.generators.nix-remote-build = {
          share = true;
          files.key = { };
          files."key.pub".secret = false;
          runtimeInputs = [ pkgs.coreutils pkgs.openssh ];
          script = ''
            ssh-keygen -t ed25519 -N "" -C "" -f "$out"/key
          '';
        };
      };
    }];

    config = {
      programs.ssh.extraConfig = ''
        Host build01
          Hostname fda9:b487:2919:3547:3699:9336:90ec:cb59

        Host build02
          Hostname build02.tailfc885e.ts.net

        Host storinator01
          Hostname fda9:b487:2919:3547:3699:9393:7f57:6e6b

        Host clan-tunnel
          Hostname clan.lol
          User tunnel
          IdentityFile ${config.clan.core.vars.generators.nix-remote-build.files.key.path}

        Match exec "echo %h | grep -q '^fda9:b487:2919:3547:3699:93'"
          ProxyJump clan-tunnel
      '';

      programs.ssh.knownHosts = {
        "clan.lol".publicKey = keys.hosts.clan.web01;

        build01 = {
          extraHostNames = [ "fda9:b487:2919:3547:3699:9336:90ec:cb59" ];
          publicKey = keys.hosts.clan.build01;
        };
      };
    };
  };
in {
  nixosModule = { options, lib, ... }: {
    imports = [ shared ];

    config = lib.optionalAttrs (options ? clan) {
      clan.core.vars.generators.tailscale = {
        share = true;
        prompts.auth-key.persist = true;
      };
    };
  };

  darwinModule = shared;
}
