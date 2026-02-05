{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.podman;
in
with lib;
{
  options.modules.podman = {
    enable = mkEnableOption "Podzz";
  };

  config = mkIf cfg.enable {
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
