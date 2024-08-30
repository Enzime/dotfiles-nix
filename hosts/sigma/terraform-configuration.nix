{ config, inputs, hostname, pkgs, lib, ... }:

{
  terraform.required_providers.onepassword.source = "1Password/onepassword";
  terraform.required_providers.local.source = "hashicorp/local";
  terraform.required_providers.tailscale.source = "tailscale/tailscale";

  provider.onepassword.account = "my.1password.com";

  data.onepassword_item.tailscale_api_key = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    uuid = "he4ygqtulfjb7dhhk3chvhrdge";
  };

  provider.tailscale.api_key =
    config.data.onepassword_item.tailscale_api_key "credential";

  resource.tailscale_tailnet_key.terraform = {
    description = "Terraform";
    expiry = 86400; # 1 day
    reusable = false;
    recreate_if_invalid = "always";
  };

  resource.onepassword_item.tailscale_auth_key = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    title = "Tailscale Auth key";
    category = "password";
    password = config.resource.tailscale_tailnet_key.terraform "key";
  };

  module.install = {
    source = "${inputs.nixos-anywhere}/terraform/install";
    target_host = hostname;
    flake = ".#${hostname}";
    build_on_remote = pkgs.system
      != inputs.self.nixosConfigurations.${hostname}.pkgs.system;
    extra_environment = {
      TAILSCALE_AUTH_KEY_UUID =
        config.resource.onepassword_item.tailscale_auth_key "uuid";
    };
    disk_encryption_key_scripts = [{
      path = "/tmp/disk.key";
      script = lib.getExe (pkgs.writeShellApplication {
        name = "get-luks-passphrase";
        text = ''
          askPassword() {
            IFS= read -r -e -p "Enter LUKS passphrase: " -s password < /dev/tty
            echo >&2
            IFS= read -r -e -p "Enter LUKS passphrase again: " -s password_check < /dev/tty
            [ "$password" = "$password_check" ]
          }

          until askPassword; do
            echo "Passwords did not match, please try again." >&2
          done

          echo "$password"
        '';
      });
    }];
    extra_files_script = lib.getExe (pkgs.writeShellApplication {
      name = "extra-files";
      # 1Password CLI requires setgid so we want to use the one from the system
      text = ''
        mkdir -p persist/etc/ssh
        op read "op://o3urqzwged2afsdmxqkjjazstq/cbhneyjvapzvchxywtz6xgrchq/private key?ssh-format=openssh" | sed 's/\r$//' > persist/etc/ssh/ssh_host_ed25519_key
        chmod 400 persist/etc/ssh/ssh_host_ed25519_key
        echo "${
          inputs.self.keys.hosts.${hostname}
        }" > persist/etc/ssh/ssh_host_ed25519_key.pub
        chmod 444 persist/etc/ssh/ssh_host_ed25519_key.pub
      '' + (lib.optionalString (inputs.self.keys.signing ? ${hostname}) ''
        mkdir -p etc/nix
        op read "op://r3fgka56ukyvdslqp3jxc37e3q/kfbpbjzox2h2qapi74p5dzqld4/key" > etc/nix/key
        chmod 400 etc/nix/key
        echo "${inputs.self.keys.signing.${hostname}}" > etc/nix/key.pub
        chmod 444 etc/nix/key.pub
      '') + ''
        op read "op://r3fgka56ukyvdslqp3jxc37e3q/$TAILSCALE_AUTH_KEY_UUID/password" > persist/tailscale.key
        chmod 400 persist/tailscale.key
      '';
    });
  };
}
