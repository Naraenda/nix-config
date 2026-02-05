{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.modules.remote;
in
with lib;
{
  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  options.modules.remote = {
    enable = mkEnableOption "Packages & services for accessing this machine remotely.";
  };

  config = mkIf cfg.enable {
    services.vscode-server = {
      enable = true;
    };
  };
}
