let
  shared =
    {
      options,
      config,
      hostname,
      keys,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        {
          config = lib.optionalAttrs (options ? clan) {
            clan.core.networking.targetHost = "root@${hostname}";

            clan.core.vars.generators.nix-remote-build = {
              share = true;
              files.key = { };
              files."key.pub".secret = false;
              runtimeInputs = [
                pkgs.coreutils
                pkgs.openssh
              ];
              script = ''
                ssh-keygen -t ed25519 -N "" -C "" -f "$out"/key
              '';
            };
          };
        }
      ];

      config = {
        programs.ssh.extraConfig = ''
          Host clan-tunnel
            Hostname clan.lol
            User tunnel
            IdentityFile ${config.clan.core.vars.generators.nix-remote-build.files.key.path}

          Match exec "echo %h | grep -q '^fda9:b487:2919:3547:3699:93'"
            ProxyJump clan-tunnel
        '';

        programs.ssh.knownHosts = {
          "clan.lol".publicKey = keys.hosts.clan.web01;

          "build01.clan.lol" = {
            extraHostNames = [ "fda9:b487:2919:3547:3699:9336:90ec:cb59" ];
            publicKey = keys.hosts.clan.build01;
          };
        };
      };
    };
in
{
  nixosModule =
    { options, lib, ... }:
    {
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
