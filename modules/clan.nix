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
          ProxyJump clan-tunnel
          Hostname fda9:b487:2919:3547:3699:9336:90ec:cb59

        Host build02
          ProxyJump clan-tunnel
          Hostname build02.tailfc885e.ts.net

        Host storinator01
          ProxyJump clan-tunnel
          Hostname fda9:b487:2919:3547:3699:9393:7f57:6e6b

        Host clan-tunnel
          Hostname clan.lol
          User tunnel
          IdentityFile ${config.clan.core.vars.generators.nix-remote-build.files.key.path}
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
  nixosModule = { options, config, pkgs, lib, ... }: {
    imports = [ shared ];

    config = lib.optionalAttrs (options ? clan) {
      clan.core.vars.generators.tailscale = {
        share = true;
        prompts.auth-key.persist = true;
      };

      clan.core.vars.generators.syncthing = {
        # We don't need to manage password hash anymore once https://github.com/NixOS/nixpkgs/pull/290485 is merged
        files.password-hash.secret = false;
        files.password.deploy =
          assert !config.services.syncthing ? guiPasswordFile;
          false;

        runtimeInputs = [ pkgs.coreutils pkgs.apacheHttpd pkgs.xkcdpass ];

        script = ''
          xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > "$out"/password
          htpasswd -niBC 10 "" < "$out"/password | tr -d ':\n' > "$out"/password-hash
        '';
      };
    };
  };

  darwinModule = shared;
}
