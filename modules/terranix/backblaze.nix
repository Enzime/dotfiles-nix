{ config, self', lib, ... }:

{
  terraform.required_providers.b2.source = "Backblaze/b2";

  data.external.b2-key-id = {
    program = [ (lib.getExe self'.packages.get-clan-secret) "b2-key-id" ];
  };

  data.external.b2-application-key = {
    program =
      [ (lib.getExe self'.packages.get-clan-secret) "b2-application-key" ];
  };

  provider.b2.application_key_id =
    config.data.external.b2-key-id "result.secret";
  provider.b2.application_key =
    config.data.external.b2-application-key "result.secret";

  resource.b2_bucket.restic = {
    bucket_name = "enzime-restic";
    bucket_type = "allPrivate";
  };
}
