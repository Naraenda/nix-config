{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.containers;
in
with lib;
{
  options.modules.containers = {
    enable = mkEnableOption "containers";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      docker = {
        enable = true;
        enableOnBoot = true;
        storageDriver = "btrfs";
      };
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
      };
    };

    environment.systemPackages = with pkgs; [
      podman
      podman-compose
      podman-tui
      buildah        # 'podman build -t my-image'
      skopeo         # 'skopeo -h'
      fuse-overlayfs # required for rootless
      slirp4netns    # required for rootless
    ];
  };
}
