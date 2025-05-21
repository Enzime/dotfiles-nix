{
  perSystem = { pkgs, ... }: {
    packages.terraform = pkgs.opentofu.withPlugins (p:
      builtins.attrValues {
        inherit (p) external hcloud local null onepassword tailscale;
      });
  };
}
