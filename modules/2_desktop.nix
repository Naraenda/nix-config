{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.desktop;
in
with lib;
{
  options.modules.desktop = {
    enable = mkEnableOption "Wayland desktop";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      sddm = {
        enable = true;
        settings = {
          General.DisplayServer = "wayland";
        };
        wayland = {
          enable = true;
        };
      }; # sddm
    }; # services.displayManager

    services.desktopManager = {
      plasma6.enable = true;
    }; # services.desktopManager

    programs.xwayland.enable = true;

    fonts.packages = with pkgs; [ 
      twitter-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
  };
}
