{ config, inputs, pkgs, lib, ... }:

{
  terraform.required_providers.hcloud.source = "hetznercloud/hcloud";
  terraform.required_providers.onepassword.source = "1Password/onepassword";
  terraform.required_providers.local.source = "hashicorp/local";

  provider.onepassword.account = "my.1password.com";

  data.onepassword_item.hcloud_token = {
    vault = "r3fgka56ukyvdslqp3jxc37e3q";
    uuid = "sjilzoukc5ouqsvq7gwkzi7amm";
  };

  provider.hcloud.token = config.data.onepassword_item.hcloud_token "password";

  resource.hcloud_ssh_key.enzime = {
    name = "enzime";
    public_key = inputs.self.keys.users.enzime;
  };

  resource.hcloud_server.aether = {
    name = "aether";
    image = "debian-12";
    server_type = "cax31";
    location = "hel1";
    ssh_keys = [ (config.resource.hcloud_ssh_key.enzime "id") ];
    shutdown_before_deletion = true;
    backups = false;
  };

  module.install = {
    source = "${inputs.nixos-anywhere}/terraform/install";
    target_host = config.resource.hcloud_server.aether "ipv4_address";
    flake = ".#aether";
    build_on_remote = true;
    extra_files_script = "${lib.getExe (pkgs.writeShellApplication {
      name = "extra-files";
      # 1Password CLI requires setgid so we want to use the one from the system
      text = ''
        mkdir -p etc/ssh etc/nix
        op read "op://r3fgka56ukyvdslqp3jxc37e3q/neshyb5ajkdjzl5k4tm5fne45u/private key?ssh-format=openssh" | sed 's/\r$//' > etc/ssh/ssh_host_ed25519_key
        chmod 400 etc/ssh/ssh_host_ed25519_key
        echo "${inputs.self.keys.hosts.aether}" > etc/ssh/ssh_host_ed25519_key.pub
        chmod 444 etc/ssh/ssh_host_ed25519_key.pub
        op read "op://r3fgka56ukyvdslqp3jxc37e3q/kfbpbjzox2h2qapi74p5dzqld4/key" > etc/nix/key
        chmod 400 etc/nix/key
        echo "${inputs.self.keys.signing.aether}" > etc/nix/key.pub
        chmod 444 etc/nix/key.pub
      '';
    })}";
  };
}
