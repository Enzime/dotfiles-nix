{
  nixosModule = { pkgs, ... }: {
    services.mullvad-vpn.enable = true;
    # Install the GUI as well
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
  };
}
