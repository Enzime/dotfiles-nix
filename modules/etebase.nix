{
  imports = [ "docker" ];

  nixosModule = { user, pkgs, utils, ... }: {
    system.activationScripts.enableLingering = ''
      rm -r /var/lib/systemd/linger
      mkdir -p /var/lib/systemd/linger
      touch /var/lib/systemd/linger/${user}
    '';

    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

    # WORKAROUND: `escapeSystemdPath` removes the root slash, but we need an escaped root slash
    systemd.services."arion@${utils.escapeSystemdPath "//home/${user}/nix/etebase-arion"}" = {
      description = "Run arion config at %I";
      after = [ "network-online.target" "nix-daemon.service" "podman.service" ];
      wants = [ "network-online.target" ];
      requires = [ "nix-daemon.service" "podman.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "%I";
        ExecStart = "${pkgs.arion}/bin/arion up";
        ExecStop = "${pkgs.arion}/bin/arion stop";
        User = "${user}";
        Group = "users";
      };
      path = let
        dockerCompat = pkgs.runCommand "podman-docker-compat" { } ''
          mkdir -p $out/bin
          ln -s ${pkgs.podman}/bin/podman $out/bin/docker
        '';
      in [ pkgs.nix pkgs.podman dockerCompat "/run/wrappers" ];
    };
  };
}
