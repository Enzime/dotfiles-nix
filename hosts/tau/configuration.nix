{ pkgs, ... }:

let
  linux-surface = (pkgs.fetchFromGitHub {
    owner = "linux-surface";
    repo = "linux-surface";
    rev = "c3d8d1999970f770e197d2a4d506c2f65dc14681";
    sha256 = "sha256-TDraXH6XmKU7/X1SQlvxJ2/9p1cipOm7dY6mKFSLV5Q=";
  });

  mapDir = f: p: builtins.attrValues (builtins.mapAttrs (k: _: f p k) (builtins.readDir p));
  patch = dir: file: { name = file; patch = dir + "/${file}"; };
  upstreamPatches = mapDir patch (linux-surface + "/patches/5.15");
in {
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPatches = upstreamPatches;

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "tau-nixos";

  networking.interfaces.wlp0s20f3.useDHCP = true;

  services.udev.extraHwdb = ''
    evdev:name:Microsoft Surface * Keyboard:dmi:*
      KEYBOARD_KEY_70039=esc
  '';

  # Check that this can be bumped before changing it
  system.stateVersion = "22.05";
}
