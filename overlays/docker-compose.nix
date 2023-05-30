self: super: {
  docker-compose_1 =
    super.runCommand "podman-compose-compat-${super.podman-compose.version}" {
      inherit (super.podman-compose) meta;
    } ''
      mkdir -p $out/bin
      ln -s ${super.podman-compose}/bin/podman-compose $out/bin/docker-compose
    '';
}
