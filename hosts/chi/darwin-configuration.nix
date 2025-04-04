{ user, keys, pkgs, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  ids.gids.nixbld = 30000;

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Projects/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Projects/nix-darwin";
  };

  system.defaults.dock.persistent-apps = [
    "~/Applications/Home Manager Apps/Firefox.app"
    "${pkgs.utm}/Applications/UTM.app"
    "/System/Applications/System Settings.app"
  ];

  nix.linux-builder.config.users.users.builder.openssh.authorizedKeys.keys =
    builtins.attrValues { inherit (keys.hosts) echo; };
  nix.linux-builder.config.virtualisation.cores = 4;

  system.stateVersion = 5;
}
