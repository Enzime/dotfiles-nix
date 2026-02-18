{ host, hostname, ... }:
{
  config,
  inputs',
  lib,
  ...
}:

let
  clan = inputs'.clan-core.packages.clan-cli;
in
{
  resource.tailscale_oauth_client."hoopsnake-${hostname}" = {
    description = "Hoopsnake on ${hostname}";
    scopes = [
      "auth_keys"
      "devices:core"
    ];
    tags = [ "tag:initrd" ];

    provisioner.local-exec = {
      command = ''
        set -ex

        echo '${lib.tf.ref "self.id"}' | ${lib.getExe clan} vars set --debug ${hostname} hoopsnake/tailscale-client-id

        echo '${lib.tf.ref "self.key"}' | ${lib.getExe clan} vars set --debug ${hostname} hoopsnake/tailscale-client-secret
      '';
    };
  };

  resource.null_resource."install-${hostname}" = {
    depends_on = [
      "tailscale_tailnet_key.terraform"
      "tailscale_oauth_client.hoopsnake-${hostname}"
    ];
    provisioner.local-exec = {
      command =
        let
          targetHost = "root@sigma-installer";
        in
        ''
          set -ex

          # Remove this section when `clan machines install --update-hardware-config nixos-facter`
          # supports writing to `hosts/<host>/facter.json`
          ${lib.getExe clan} machines install ${hostname} \
            --update-hardware-config nixos-facter \
            --target-host ${targetHost} \
            -i '${config.resource.local_sensitive_file.ssh_deploy_key "filename"}' \
            --phases kexec \
            --yes --debug

          mv machines/${host}/facter.json hosts/${host}
          rm -d machines/${host}
          rm -d machines

          ${lib.getExe clan} machines install ${hostname} \
            --target-host ${targetHost} \
            --build-on remote \
            -i '${config.resource.local_sensitive_file.ssh_deploy_key "filename"}' \
            --phases disko,install,reboot \
            --yes --debug
        '';
    };
  };
}
