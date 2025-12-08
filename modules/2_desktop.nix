{
  lib,
  config,
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
  };
}
