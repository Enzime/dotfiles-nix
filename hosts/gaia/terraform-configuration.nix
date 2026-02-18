{
  host,
  hostname,
  keys,
  ...
}:
{
  config,
  self',
  inputs',
  lib,
  ...
}:

let
  clan = inputs'.clan-core.packages.clan-cli;
in
{
  terraform.required_providers.vultr.source = "vultr/vultr";

  data.external.vultr-api-key = {
    program = [
      (lib.getExe self'.packages.get-clan-secret)
      "vultr-api-key"
    ];
  };

  provider.vultr.api_key = config.data.external.vultr-api-key "result.secret";

  resource.vultr_ssh_key.enzime = {
    name = "Enzime";
    ssh_key = keys.users.enzime;
  };

  resource.vultr_ssh_key.terraform = {
    name = "Terraform";
    ssh_key = lib.tf.ref "trimspace(tls_private_key.ssh_deploy_key.public_key_openssh)";
  };

  data.vultr_os.debian = {
    filter = {
      name = "name";
      values = [ "Debian 13 x64 (trixie)" ];
    };
  };

  resource.vultr_instance.${hostname} = {
    label = hostname;
    region = "sgp";
    plan = "vc2-2c-4gb";
    os_id = config.data.vultr_os.debian "id";
    enable_ipv6 = true;
    ssh_key_ids = [
      (config.resource.vultr_ssh_key.terraform "id")
      (config.resource.vultr_ssh_key.enzime "id")
    ];
    backups = "disabled";
  };

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

  # WORKAROUND: Append `true` to `.bashrc` as `ssh-copy-id` can't handle
  # when `ssh user@host exit` returns a non-zero exit code which occurs
  # when `bash` is your login shell and the last command in `.bashrc`
  # returns a non-zero exit code.
  resource.null_resource."install-${hostname}" = {
    triggers = {
      instance_id = config.resource.vultr_instance.${hostname} "id";
    };
    depends_on = [
      "tailscale_tailnet_key.terraform"
      "tailscale_oauth_client.hoopsnake-${hostname}"
    ];
    provisioner.local-exec = {
      command =
        let
          targetHost = "root@${config.resource.vultr_instance.${hostname} "main_ip"}";
          sshKey = config.resource.local_sensitive_file.ssh_deploy_key "filename";
        in
        ''
          set -ex

          until ssh -o IdentitiesOnly=yes -i '${sshKey}' -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new ${targetHost} exit 0; do
            sleep 5
          done

          if ! ssh -o IdentitiesOnly=yes -i '${sshKey}' ${targetHost} exit; then
            ssh -o IdentitiesOnly=yes -i '${sshKey}' ${targetHost} "echo true >> ~/.bashrc"
          fi

          # assert that it worked!
          ssh -o IdentitiesOnly=yes -i '${sshKey}' ${targetHost} exit

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
          git add --intent-to-add machines/gaia/facter.json

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
