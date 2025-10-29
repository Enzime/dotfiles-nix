{ hostname, ... }:
{ config, inputs', lib, ... }:

let clan = inputs'.clan-core.packages.clan-cli;
in {
  resource.b2_application_key.restic = {
    key_name = "restic";
    # default list when manually creating application key through Backblaze web interface
    capabilities = [
      "deleteFiles"
      "listBuckets"
      "listFiles"
      "readBucketEncryption"
      "readBucketLogging"
      "readBucketNotifications"
      "readBucketReplications"
      "readBuckets"
      "readFiles"
      "shareFiles"
      "writeBucketEncryption"
      "writeBucketLogging"
      "writeBucketNotifications"
      "writeBucketReplications"
      "writeBuckets"
      "writeFiles"
    ];
    bucket_id = config.resource.b2_bucket.restic "id";

    provisioner.local-exec = {
      command = ''
        set -ex

        echo '${lib.tf.ref "self.application_key_id"}' | ${
          lib.getExe clan
        } vars set --debug ${hostname} restic-backblaze/key-id

        echo '${lib.tf.ref "self.application_key"}' | ${
          lib.getExe clan
        } vars set --debug ${hostname} restic-backblaze/app-key

        ${
          lib.getExe clan
        } vars generate --debug ${hostname} --generator restic-backblaze-environment
      '';
    };
  };
}
