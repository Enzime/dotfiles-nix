{
  imports = [ "firefox" "fonts" ];

  nixosModule = { user, pkgs, ... }: {
    environment.systemPackages =
      builtins.attrValues { inherit (pkgs) pavucontrol; };

    services.xserver.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.alsa.support32Bit = true;
    services.pipewire.pulse.enable = true;
  };
}

