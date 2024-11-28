{ user, keys, pkgs, lib, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  launchd.user.agents.echo = {
    command = "${lib.getExe' pkgs.utm "utmctl"} start echo";
    serviceConfig.RunAtLoad = true;
  };

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
    # Update this when firefox-bin-unwrapped is merged
    (assert pkgs.firefox.meta.unsupported && pkgs.firefox-bin.meta.unsupported;
      "/Applications/Firefox.app")
    "${pkgs.utm}/Applications/UTM.app"
    "/System/Applications/System Settings.app"
  ];

  nix.linux-builder.config.users.users.builder.openssh.authorizedKeys.keys =
    builtins.attrValues { inherit (keys.hosts) echo; };
  nix.linux-builder.config.virtualisation.cores = 4;

  system.stateVersion = 5;
}
