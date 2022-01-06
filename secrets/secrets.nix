let
  users = {
    enzime_phi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzD/3cOhlqe8NVEruSUnPSnG1GbmX8SgTbVGLFHMa7g";
    enzime_tau = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqDFjlA1zdrYy9lyv9TQrXJF89fgxcWRZSiU/xDoog/";
  };

  hosts = {
    phi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxOi/S1TLBg8/ZRX5XfCTlM8A+I0q0pQksrxtfjdYFP";
    tau = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4Yk5eL/z/I9KhXm1ZsOBQiIBgdGZe1xUTz8whBWe4u";
  };
in {
  "aws_config.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_tau;
    inherit (hosts) tau;
  };

  "duckdns.age".publicKeys = builtins.attrValues {
    inherit (users) enzime_phi;
    inherit (hosts) phi;
  };
}
