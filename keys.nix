{
  users = {
    enzime =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKZfejb9htpSB5K9p0RuEowErkba2BMKaze93ZVkQIE";
  };

  hosts = {
    aether =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHz2SZ0cO7lBQrzuGrY2HcUs1R2ty7s9FyWzSkJxt9y";
    echo =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9lGmlJLo3tQoCfyplj2pWoIdB0lPZJm4cEdo/rKExR";
    hermes-nixos =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc0GhOQvfKE6r+6oYRjGCepenZZiSNh+czkAqM2IAdK";
    phi =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxOi/S1TLBg8/ZRX5XfCTlM8A+I0q0pQksrxtfjdYFP";
    sigma =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxRoznXzz/T6s5UeHG1uoHCXGfXSpy27eTEzC0/EUW+";
  };

  signing = {
    "enzime.cachix.org" =
      "enzime.cachix.org-1:RvUdpEy6SEXlqvKYOVHpn5lNsJRsAZs6vVK1MFqJ9k4=";
    aether = "aether-1:fMOnq1aouEVTB6pz6TvszTrXQhrQAbPePlilPafmsHs=";
    chi-linux-builder =
      "chi-linux-builder-1:u0hwDFmxev8B65kKbSAjBP7nGR+it429j/UbsdZd3gs=";
  };
}
