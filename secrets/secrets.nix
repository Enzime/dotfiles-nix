let
  users = {
    enzime_phi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzD/3cOhlqe8NVEruSUnPSnG1GbmX8SgTbVGLFHMa7g";
  };

  hosts = {
    phi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxOi/S1TLBg8/ZRX5XfCTlM8A+I0q0pQksrxtfjdYFP";
  };
in {
  "duckdns.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };
}
