{ user, config, pkgs, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  ids.gids.nixbld = 30000;

  nix.registry.ln.to = {
    type = "git";
    url = "file://${config.users.users.${user}.home}/Projects/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file://${config.users.users.${user}.home}/Projects/nix-darwin";
  };

  system.defaults.dock.persistent-apps = [
    "~/Applications/Home Manager Apps/Firefox.app"
    "${pkgs.utm}/Applications/UTM.app"
    "/System/Applications/System Settings.app"
  ];

  nix.linux-builder.config.virtualisation.cores = 4;

  system.stateVersion = 5;
}
