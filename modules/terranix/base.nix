{ config, self', inputs', lib, ... }:

let clan = inputs'.clan-core.packages.clan-cli;
in {
  terraform.required_providers.local.source = "hashicorp/local";
  terraform.required_providers.onepassword.source = "1Password/onepassword";
  terraform.required_providers.tailscale.source = "tailscale/tailscale";
  terraform.required_providers.tls.source = "hashicorp/tls";

  provider.onepassword.account = "my.1password.com";

  data.external.tailscale-api-key = {
    program =
      [ (lib.getExe self'.packages.get-clan-secret) "tailscale-api-key" ];
  };

  provider.tailscale.api_key =
    config.data.external.tailscale-api-key "result.secret";

  resource.tailscale_tailnet_key.terraform = {
    description = "Terraform";
    expiry = 7776000; # 90 days
    reusable = true;
    preauthorized = true;
    recreate_if_invalid = "always";

    # We hardcode the machine as `sigma` as we don't have access to
    # `hostname` however any machine would work as this is shared
    # between all machines.
    provisioner.local-exec = {
      command =
        "echo '${config.resource.tailscale_tailnet_key.terraform "key"}' | ${
          lib.getExe clan
        } vars set --debug sigma tailscale/auth-key";
    };
  };

  resource.tls_private_key.ssh_deploy_key = { algorithm = "ED25519"; };

  resource.local_sensitive_file.ssh_deploy_key = {
    filename = "${lib.tf.ref "path.module"}/.terraform-deploy-key";
    file_permission = "600";
    content =
      config.resource.tls_private_key.ssh_deploy_key "private_key_openssh";
  };
}
