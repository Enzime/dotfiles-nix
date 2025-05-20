{ config, self', inputs', hostname, keys, lib, ... }:

let clan = inputs'.clan-core.packages.clan-cli;
in {
  terraform.required_providers.local.source = "hashicorp/local";
  terraform.required_providers.tailscale.source = "tailscale/tailscale";
  terraform.required_providers.tls.source = "hashicorp/tls";
  terraform.required_providers.vultr.source = "vultr/vultr";

  data.external.vultr-api-key = {
    program = [ (lib.getExe self'.packages.get-clan-secret) "vultr-api-key" ];
  };

  data.external.tailscale-api-key = {
    program =
      [ (lib.getExe self'.packages.get-clan-secret) "tailscale-api-key" ];
  };

  provider.vultr.api_key = config.data.external.vultr-api-key "result.secret";
  provider.tailscale.api_key =
    config.data.external.tailscale-api-key "result.secret";

  resource.tls_private_key.ssh_deploy_key = { algorithm = "ED25519"; };

  resource.local_sensitive_file.ssh_deploy_key = {
    filename = "${lib.tf.ref "path.module"}/.terraform-deploy-key";
    file_permission = "600";
    content =
      config.resource.tls_private_key.ssh_deploy_key "private_key_openssh";
  };

  resource.vultr_ssh_key.enzime = {
    name = "Enzime";
    ssh_key = keys.users.enzime;
  };

  resource.vultr_ssh_key.terraform = {
    name = "Terraform";
    ssh_key =
      config.resource.tls_private_key.ssh_deploy_key "public_key_openssh";
  };

  resource.vultr_instance.${hostname} = {
    label = hostname;
    region = "sgp";
    plan = "vc2-2c-4gb";
    # Debian 12
    os_id = 2136;
    enable_ipv6 = true;
    ssh_key_ids = [
      (config.resource.vultr_ssh_key.terraform "id")
      (config.resource.vultr_ssh_key.enzime "id")
    ];
    backups = "disabled";
  };

  resource.tailscale_tailnet_key.terraform = {
    description = "Terraform";
    expiry = 86400; # 1 day
    reusable = false;
    preauthorized = true;
    recreate_if_invalid = "always";

    provisioner.local-exec = {
      command =
        "echo '${config.resource.tailscale_tailnet_key.terraform "key"}' | ${
          lib.getExe clan
        } vars set --debug ${hostname} tailscale/auth-key";
    };
  };

  # TODO: SSH host keys in vars

  # Manually append `true` to `.bashrc` to workaround `ssh-copy-id` bug
  resource.null_resource."install-${hostname}" = {
    triggers = {
      instance_id = config.resource.vultr_instance.${hostname} "id";
    };
    depends_on = [ "tailscale_tailnet_key.terraform" ];
    provisioner.local-exec = {
      command = let
        targetHost =
          "root@${config.resource.vultr_instance.${hostname} "main_ip"}";
        sshKey = config.resource.local_sensitive_file.ssh_deploy_key "filename";
      in ''
        set -e

        until ssh -o IdentitiesOnly=yes -i '${sshKey}' -o ConnectTimeout=10 ${targetHost} exit 0; do
          sleep 5
        done

        if ! ssh -o IdentitiesOnly=yes -i '${sshKey}' ${targetHost} exit; then
          ssh -o IdentitiesOnly=yes -i '${sshKey}' ${targetHost} "echo true >> ~/.bashrc"
        fi

        # assert that it worked!
        ssh -o IdentitiesOnly=yes -i '${sshKey}' ${targetHost} exit

        ${lib.getExe clan} machines install ${hostname} \
          --update-hardware-config nixos-facter \
          --target-host ${targetHost} \
          -i '${
            config.resource.local_sensitive_file.ssh_deploy_key "filename"
          }' \
          --yes --debug
      '';
    };
  };
}
