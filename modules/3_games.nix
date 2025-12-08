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
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
