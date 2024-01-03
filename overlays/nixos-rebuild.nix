self: super: {
  nixos-rebuild = super.nixos-rebuild.overrideAttrs (old:
    let
      patches = [
        (super.fetchpatch {
          name = "fix-cross-building-flakes.patch";
          url =
            "https://github.com/Enzime/nixpkgs/commit/6a504caae83fce4fe5e345f6c1ee4cf3f7f4fb09.patch";
          sha256 = "sha256-Rg+xo+Qr/TK5L8YBMnsIKoGwf0LHI/e+svJFvARtWnM=";
        })

        (super.fetchpatch {
          name = "only-use-sudo-when-necessary.patch";
          url =
            "https://github.com/Enzime/nixpkgs/commit/385898edebd54babf29ee356fac4492e64657783.patch";
          includes =
            [ "pkgs/os-specific/linux/nixos-rebuild/nixos-rebuild.sh" ];
          sha256 = "sha256-oECc8KsCgFeQ0c7w/cRavehuqaWd+yHW+dvaDDG9zgQ=";
        })

        (super.fetchpatch {
          name = "fix-sudo-password-over-ssh.patch";
          url =
            "https://github.com/Enzime/nixpkgs/commit/6e18bb21cdfc4395386b60f93eef98e5d9a26762.patch";
          sha256 = "sha256-1Y9mqCXEBUxoLU3DZXVuhPPdeFCro6zZnrv2QGedkcw=";
        })

        (super.fetchpatch {
          name = "fix-systemd-run-hang-over-ssh.patch";
          url =
            "https://github.com/Enzime/nixpkgs/commit/dda66bb0a46d0886723b7276744b6a4ebef683c2.patch";
          sha256 = "sha256-4zWnfW8gGNWnCeQvDcke22iTuXdvcirndF+pXv97JYo=";
        })
      ];
    in {
      postInstall = builtins.concatStringsSep "\n"
        ((map (p: "patch --no-backup-if-mismatch $target ${p}") patches)
          ++ [ (old.postInstall or "") ]);
    });
}
