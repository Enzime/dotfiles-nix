{
  perSystem = { inputs', pkgs, ... }: {
    packages.terraform = pkgs.opentofu.withPlugins (p:
      builtins.attrValues {
        inherit (p) external hcloud local null onepassword tailscale tls vultr;
      });

    packages.get-clan-secret = pkgs.writeShellApplication {
      name = "get-clan-secret";
      runtimeInputs = builtins.attrValues {
        inherit (pkgs) jq;
        inherit (inputs'.clan-core.packages) clan-cli;
      };
      text = ''
        jq -n --arg secret "$(clan secrets get "$1")" '{"secret":$secret}'
      '';
    };
  };
}
