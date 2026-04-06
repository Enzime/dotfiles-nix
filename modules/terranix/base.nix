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
  terraform.backend.s3 = {
    endpoints.s3 = "https://s3.us-west-001.backblazeb2.com";
    bucket = "enzime-dotfiles-tf-state";
    key = "tofu.tfstate";
    region = "us-west-001";

    skip_credentials_validation = true;
    skip_region_validation = true;
    skip_metadata_api_check = true;
    skip_requesting_account_id = true;
    skip_s3_checksum = true;

    skip_bucket_root_access = true;
    skip_bucket_enforced_tls = true;
    skip_bucket_ssencryption = true;
    skip_bucket_public_access_blocking = true;
  };

  terraform.encryption = {
    key_provider.external.passphrase = {
      command = [ (lib.getExe self'.packages.provide-tf-passphrase) ];
    };

    key_provider.pbkdf2.state_encryption_password = {
      chain = lib.tf.ref "key_provider.external.passphrase";
    };

    method.aes_gcm.encryption_method.keys = lib.tf.ref "key_provider.pbkdf2.state_encryption_password";

    state.enforced = true;
    state.method = "method.aes_gcm.encryption_method";

    plan.enforced = true;
    plan.method = "method.aes_gcm.encryption_method";
  };

  terraform.required_providers.local.source = "hashicorp/local";
  terraform.required_providers.onepassword.source = "1Password/onepassword";
  terraform.required_providers.tailscale.source = "tailscale/tailscale";
  terraform.required_providers.tls.source = "hashicorp/tls";

  provider.onepassword.account = "my.1password.com";

  data.onepassword_item.tailscale-oauth-client = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    title = "Tailscale OAuth client";
  };

  provider.tailscale.oauth_client_id = config.data.onepassword_item.tailscale-oauth-client "username";
  provider.tailscale.oauth_client_secret = config.data.onepassword_item.tailscale-oauth-client "password";

  resource.tailscale_oauth_client.terraform = {
    description = "Terraform";
    scopes = [ "all" ];

    lifecycle.create_before_destroy = true;
  };

  resource.onepassword_item.tailscale-oauth-client = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    title = "Tailscale OAuth client";
    # They only support reading API Credentials from the Terraform provider
    category = "login";
    username = config.resource.tailscale_oauth_client.terraform "id";
    password = config.resource.tailscale_oauth_client.terraform "key";
  };

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
      command = "echo '${config.resource.tailscale_tailnet_key.terraform "key"}' | ${lib.getExe clan} vars set --debug sigma tailscale/auth-key";
    };
  };

  resource.tls_private_key.ssh_deploy_key = {
    algorithm = "ED25519";
  };

  resource.local_sensitive_file.ssh_deploy_key = {
    filename = "${lib.tf.ref "path.module"}/.terraform-deploy-key";
    file_permission = "600";
    content = config.resource.tls_private_key.ssh_deploy_key "private_key_openssh";
  };
}
