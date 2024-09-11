{ user, pkgs, lib, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  launchd.user.agents.echo = {
    serviceConfig.ProgramArguments = [
      "/bin/sh"
      "-c"
      ''
        /bin/wait4path /nix/store &amp;&amp; exec "${
          lib.getExe' pkgs.utm "utmctl"
        }" start echo''
    ];
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
}
