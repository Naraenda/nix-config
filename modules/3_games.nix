{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.games;
in
with lib;
{
  options.modules.games = {
    enable = mkEnableOption "Become gamer :3";
  };

  config = mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    services.udev.extraRules = ''
        # YuanCon Controller Mapping
        KERNEL=="hidraw*", ATTRS{idVendor}=="1ccf", ATTRS{idProduct}=="101c", MODE="0666", TAG+="uaccess"
      '';
  };
}
