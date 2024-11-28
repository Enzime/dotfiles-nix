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
    (assert pkgs.firefox.meta.unsupported && pkgs.firefox-bin.meta.unsupported;
      "/Applications/Firefox.app")
    "/System/Applications/Utilities/Terminal.app"
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

  system.stateVersion = 5;
}
