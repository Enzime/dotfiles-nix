{
  users = {
    enzime =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKZfejb9htpSB5K9p0RuEowErkba2BMKaze93ZVkQIE";
    nathan =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/8b0o0mOY2IAadhWxLzDqunZUa9cqh+amVxExKD5co";
  };

  hosts = {
    phi =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxOi/S1TLBg8/ZRX5XfCTlM8A+I0q0pQksrxtfjdYFP";
    sigma =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxRoznXzz/T6s5UeHG1uoHCXGfXSpy27eTEzC0/EUW+";

    clan = {
      web01 =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDypEkNI1qtN/+MBDFfSSuoZm8g2oj4wBaFoUqTWC0JF";

      build01 =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUr97pcoz2RGJT9VDk1zv+1yxJCPRp1X4f/8vwd1Z7V";
    };
  };

  signing = {
    "enzime.cachix.org" =
      "enzime.cachix.org-1:RvUdpEy6SEXlqvKYOVHpn5lNsJRsAZs6vVK1MFqJ9k4=";
    aether = "aether-1:fMOnq1aouEVTB6pz6TvszTrXQhrQAbPePlilPafmsHs=";
    chi-linux-builder =
      "chi-linux-builder-1:u0hwDFmxev8B65kKbSAjBP7nGR+it429j/UbsdZd3gs=";
    echo = "echo-1:B0HChd9IxG8P9V2NezeWCBsst8AdVTxesCiePZUaduc=";
    hermes-macos =
      "hermes-macos-1:H8qFV4OhrWSbfHsQV6R2VzE2t3N+3nzItt856oWG0Kc=";
    hermes-linux-builder =
      "hermes-linux-builder-1:tibNs5BpVb54V17EimjfobHDgut+y9cfHMD57vojLmo=";

    clan = {
      cache = "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28=";

      build01 = "build01-1:IqW8nGF/1I5wsTSn8tytzaTI+/4+4qkZ4HVKHTN1yfY=";
      build02 = "build02-1:niCWHDbtJ8q51n53apuW28B4BoNbqh7rwBfm2A4XeyI=";
      build-x86-01 =
        "build-x86-01-1:6ttBEKGF+6oOGJCQDbbaylpXmVcgoXNuKqlDHRsMv5Q=";
    };
  };
}
