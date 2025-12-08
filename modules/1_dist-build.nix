{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.dist-build;
in
with lib;
{
  options.modules.dist-build = {
    enable = mkEnableOption "Become fast";
  };

  config = mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "fafnir";
        sshUser = "nixremote";

        systems = [
          "x86_64-linux"
          "i686-linux"
          "aarch64-linux"
        ];
        protocol = "ssh-ng";
        maxJobs = 64;
        speedFactor = 32;
        supportedFeatures = [
          "nixos-test"
          "big-parallel"
        ];
        mandatoryFeatures = [ "big-parallel" ];
      }
    ];

    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
