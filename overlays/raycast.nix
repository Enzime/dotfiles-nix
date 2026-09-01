self: super: {
  raycast = super.raycast.overrideAttrs {
    version = "1.104.25";

    src = super.fetchurl {
      name = "Raycast.dmg";
      url = "https://releases.raycast.com/releases/1.104.25/download?build=arm";
      hash = "sha256-ly9t4hD/ys+h/u4JW4owx+65cukUyHb2XTfSGDVKcGc=";
    };
  };
}
