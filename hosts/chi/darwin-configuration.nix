{ user, ... }:

{
  networking.knownNetworkServices = [ "Ethernet" "Wi-Fi" ];

  # WORKAROUND: Using MagicDNS (through nix-darwin) without setting a fallback
  # DNS server leads to taking a lot longer to connect to the internet.
  networking.dns = [ "1.1.1.1" ];

  services.tailscale.magicDNS.enable = true;

  nix.registry.ln.to = { type = "git"; url = "file:///Users/${user}/Projects/nixpkgs"; };
  nix.registry.lnd.to = { type = "git"; url = "file:///Users/${user}/Projects/nix-darwin"; };

  # WORKAROUND: Screensaver starts on the login screen and cannot be closed from VNC
  system.activationScripts.extraActivation.text = ''
    defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0
  '';
}
