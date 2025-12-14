{
  pkgs,
  config,
  # TODO: fix this uggly hack
  enableCuda ? config.cudaSupport ? config.nixpkgs.config.cudaSupport,
  ...
}: let 
  mkPackage = deriv: extraPkgs: pkgs.callPackage deriv ({ inherit config enableCuda; } // extraPkgs);
in 
{
  # Get bleeding edge git builds :3

  # Special fork of xrizer that has support for generic
  # trackers and other nifty things:
  #   https://github.com/ImSapphire/xrizer/tree/next
  xrizer-git = mkPackage ./xrizer-git { };

  # Just building latest monado:
  #   https://gitlab.freedesktop.org/monado/monado/
  monado-git = mkPackage ./monado-git {
    gst-plugins-base = pkgs.gst_all_1.gst-plugins-base;
    gstreamer = pkgs.gst_all_1.gstreamer;
  };
  # TODO: actually build this instead of just wrapping the
  # appimage. I guess it works but still...
  vrcft-avalonia = mkPackage ./vrcft-avalonia { };

  # This shit so bleeding edge, I could cut the heavens in two.
  # We're using the following package:
  #   https://github.com/NixOS/nixpkgs/pull/459868
  # But modify it to build this fork:
  #   https://gitlab.com/0x8081/baballonia/-/tree/bsb2e_linux
  baballonia-git = mkPackage ./baballonia-git { };
  baballonia-git-cuda = mkPackage ./baballonia-git { enableCuda = true; };
}
