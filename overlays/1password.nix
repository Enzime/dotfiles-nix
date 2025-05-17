self: super: {
  _1password-gui = super._1password-gui.overrideAttrs (old: {
    version = assert super.lib.versionOlder old.version "8.10.76"; "8.10.76";

    src = assert super.lib.versionOlder old.version "8.10.76";
      super.fetchurl {
        "x86_64-linux" = {
          "url" =
            "https://downloads.1password.com/linux/tar/stable/x86_64/1password-8.10.76.x64.tar.gz";
          "hash" = "sha256-vEbmZP0WQ0Ha92V/owFKtxavahWMpV73vRiflZ1dpzQ=";
        };
        "aarch64-linux" = {
          "url" =
            "https://downloads.1password.com/linux/tar/stable/aarch64/1password-8.10.76.arm64.tar.gz";
          "hash" = "sha256-4GHFLlpThIJ5oAVgwXUAy4Gb0569RLXK1kdLErOr6j8=";
        };
        "x86_64-darwin" = {
          "url" =
            "https://downloads.1password.com/mac/1Password-8.10.76-x86_64.zip";
          "hash" = "sha256-hAIVQ7QVpZzQqW5ikCjp6HsskQWH5bbzM85DNyY0hFQ=";
        };
        "aarch64-darwin" = {
          "url" =
            "https://downloads.1password.com/mac/1Password-8.10.76-aarch64.zip";
          "hash" = "sha256-jfdtLBsd1IvntJHZOJ0pxIrwjIUOcG3thfyjTMNIMK4=";
        };
      }.${super.hostPlatform.system};
  });
}
