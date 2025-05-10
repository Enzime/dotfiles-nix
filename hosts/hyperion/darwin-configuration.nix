{ user, pkgs, ... }:

{
  networking.knownNetworkServices = [ "Wi-Fi" ];

  nix.registry.ln.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nixpkgs";
  };
  nix.registry.lnd.to = {
    type = "git";
    url = "file:///Users/${user}/Code/nix-darwin";
  };

  system.defaults.dock.persistent-apps = [
    "${pkgs.firefox-bin}/Applications/Firefox.app"
    "${pkgs.ghostty-bin}/Applications/Ghostty.app"
    "/Applications/1Password.app"
    "${pkgs.vscode}/Applications/Visual Studio Code.app"
    "${pkgs.spotify}/Applications/Spotify.app"
    "/System/Applications/Calendar.app"
    "${pkgs.joplin-desktop}/Applications/Joplin.app"
    "/System/Applications/System Settings.app"
    "/System/Applications/iPhone Mirroring.app"
  ];

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

  system.stateVersion = 6;
}
