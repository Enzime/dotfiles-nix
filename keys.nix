{
  users = {
    enzime =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKZfejb9htpSB5K9p0RuEowErkba2BMKaze93ZVkQIE";
    enzime_phi =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzD/3cOhlqe8NVEruSUnPSnG1GbmX8SgTbVGLFHMa7g";
    enzime_sigma =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwM0sVLdolDXb7LyKMT6Jfym0dP1NSgJClHcIOga+fa";
  };

  hosts = {
    achilles =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVe7IzmmpOy7zhqQoxPrSgFQHpeCEwFuIRO/vEEfEJn";
    echo =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9lGmlJLo3tQoCfyplj2pWoIdB0lPZJm4cEdo/rKExR";
    phi =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxOi/S1TLBg8/ZRX5XfCTlM8A+I0q0pQksrxtfjdYFP";
    sigma =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxRoznXzz/T6s5UeHG1uoHCXGfXSpy27eTEzC0/EUW+";
  };

  signing = {
    "enzime.cachix.org" =
      "enzime.cachix.org-1:RvUdpEy6SEXlqvKYOVHpn5lNsJRsAZs6vVK1MFqJ9k4=";
    chi-linux-builder =
      "chi-linux-builder-1:u0hwDFmxev8B65kKbSAjBP7nGR+it429j/UbsdZd3gs=";
  };
}
