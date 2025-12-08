{
  pkgs,
  ...
}:
{
  # Get bleeding edge git builds :3

  # Special fork of xrizer that has support for generic
  # trackers and other nifty things:
  #   https://github.com/ImSapphire/xrizer/tree/next
  xrizer-git = pkgs.callPackage ./xrizer-git { };

  # Just building latest monado:
  #   https://gitlab.freedesktop.org/monado/monado/
  monado-git = pkgs.callPackage ./monado-git {
    gst-plugins-base = pkgs.gst_all_1.gst-plugins-base;
    gstreamer = pkgs.gst_all_1.gstreamer;
  };
  # TODO: actually build this instead of just wrapping the
  # appimage. I guess it works but still...
  vrcft-avalonia = pkgs.callPackage ./vrcft-avalonia { };

  # This shit so bleeding edge, I could cut the heavens in two.
  # We're using the following package:
  #   https://github.com/NixOS/nixpkgs/pull/459868
  # But modify it to build this fork:
  #   https://gitlab.com/0x8081/baballonia/-/tree/bsb2e_linux
  baballonia-git = pkgs.callPackage ./baballonia-git { };
}
