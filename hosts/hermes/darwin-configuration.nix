{ user, pkgs, ... }:

{
  networking.knownNetworkServices = [ "Wi-Fi" ];

  system.activationScripts.extraActivation.text = ''
    nvram StartupMute=%01
  '';

  ids.gids.nixbld = 30000;

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nix-darwin";
  };

  system.defaults.dock.persistent-apps = [
    # Update this when firefox-bin-unwrapped is merged
    (assert pkgs.firefox-bin.meta.unsupported; "/Applications/Firefox.app")
    "/Applications/Ghostty.app"
    "/Applications/1Password.app"
    "${pkgs.vscode}/Applications/Visual Studio Code.app"
    "${pkgs.spotify}/Applications/Spotify.app"
    "/System/Applications/Calendar.app"
    "/Applications/Joplin.app"
    "/System/Applications/System Settings.app"
    "/System/Applications/iPhone Mirroring.app"
  ];

  nix.linux-builder.config.virtualisation.cores = 4;
  nix.linux-builder.config.virtualisation.darwin-builder.diskSize = 50
    * 1024; # 50 GiB

  nix.distributedBuilds = true;

  nix.buildMachines = [{
    # Use ssh-ng for trustless remote building of input-addressed derivations
    # i.e. not requiring remote user to be a trusted-user
    protocol = "ssh-ng";
    hostName = "clan.lol";
    sshUser = "enzime";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    system = "x86_64-linux";
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    maxJobs = 96;
  }];

  system.stateVersion = 5;
}
