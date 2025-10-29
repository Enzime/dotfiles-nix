{
  nixosModule = { options, config, pkgs, lib, ... }: {
    imports = [{
      config = lib.optionalAttrs (options ? clan) {
        clan.core.vars.generators.restic = {
          files.password = { };
          runtimeInputs = [ pkgs.coreutils pkgs.xkcdpass ];
          script = ''
            xkcdpass --numwords 6 --random-delimiters --valid-delimiters='1234567890!@#$%^&*()-_+=,.<>/?' --case random | tr -d "\n" > $out/password
          '';
        };

        clan.core.vars.generators.restic-backblaze = {
          prompts.key-id.persist = true;
          prompts.app-key.persist = true;
          files.key-id.deploy = false;
          files.app-key.deploy = false;
        };

        clan.core.vars.generators.restic-backblaze-environment = {
          files.environment = { };
          dependencies = [ "restic-backblaze" ];
          script = ''
            keyId=$(<$in/restic-backblaze/key-id)
            appKey=$(<$in/restic-backblaze/app-key)
            printf 'AWS_ACCESS_KEY_ID="%s"\n' $keyId >> $out/environment
            printf 'AWS_SECRET_ACCESS_KEY="%s"\n' $appKey >> $out/environment
          '';
        };
      };
    }];

    services.restic.backups.b2 = {
      repository = "s3:https://s3.us-west-001.backblazeb2.com/enzime-restic";
      environmentFile =
        config.clan.core.vars.generators.restic-backblaze-environment.files.environment.path;
      passwordFile =
        config.clan.core.vars.generators.restic.files.password.path;

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];

      # From https://restic.readthedocs.io/en/stable/080_examples.html#full-backup-without-root
      exclude =
        [ "/dev/*" "/mnt/*" "/proc/*" "/run/*" "/sys/*" "/tmp/*" "/var/tmp/*" ];

      extraBackupArgs = [ "-vv" ];
    };
  };
}
