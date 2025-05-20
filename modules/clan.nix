let
  shared = { options, hostname, lib, ... }: {
    config = lib.optionalAttrs (options ? clan) {
      clan.core.networking.targetHost = "root@${hostname}";
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
        # can be secret once https://github.com/NixOS/nixpkgs/pull/290485 is merged
        files.password-hash.secret = false;
        files.password.deploy = false;

        runtimeInputs = [ pkgs.coreutils pkgs.mkpasswd pkgs.xkcdpass ];

        script = ''
          xkcdpass --numwords 3 --delimiter - --count 1 | tr -d "\n" > "$out"/password
          mkpasswd -s -m sha-512 < "$out"/password | tr -d "\n" > "$out"/password-hash
        '';
      };

      # We still want to use the SSH host keys even if we disable OpenSSH
      sops.age.sshKeyPaths = lib.mkIf (!config.services.openssh.enable)
        (lib.optionals (!config.services.openssh.enable)
          (assert options.sops.age.sshKeyPaths.default == [ ];
            [ "/etc/ssh/ssh_host_ed25519_key" ]));
    };
  };

  darwinModule = shared;

  homeModule = {
    home.file.".ssh/config".text = ''
      Host build01
        ProxyJump tunnel@clan.lol
        Hostname fda9:b487:2919:3547:3699:9336:90ec:cb59

      Host build02
        ProxyJump tunnel@clan.lol
        Hostname build02.tailfc885e.ts.net

      Host storinator01
        ProxyJump tunnel@clan.lol
        Hostname fda9:b487:2919:3547:3699:9393:7f57:6e6b
    '';
  };
}
