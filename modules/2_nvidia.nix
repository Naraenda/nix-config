{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.nvidia;
in
with lib;
{
  options.modules.nvidia = {
    enable = mkEnableOption "Nvidia hardware support";
    cuda = mkEnableOption "CUDA support";
    bsbPatch = mkEnableOption "BigScreen Beyond patch";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      services.xserver.videoDrivers = [
        "nvidia"
      ];

      # Configure GPU drivers.
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;

        # Open kernel modules are required for wired VR.
        # https://lvra.gitlab.io/docs/hardware/
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest.overrideAttrs (prev: {
          open = prev.passthru.open.overrideAttrs (oldOpen: {
            # Apply patches to the open kernel modules source
            patches = (
                oldOpen.patches or []
              ) ++ (
                lib.optionals cfg.bsbPatch [ 
                  ../patches/nvidia/bsb-dsc/0001-fix-dsc-correct-RC-parameter-tables-to-match-VESA-DS.patch
                  ../patches/nvidia/bsb-dsc/0002-fix-dsc-use-bits_per_component-for-flatnessDetThresh.patch
                  ../patches/nvidia/bsb-dsc/0003-fix-dp-add-Bigscreen-Beyond-VR-headset-to-WAR-databa.patch
                ] # cfg.bsbPatch
              ); # patches
            }); # open
        }); # package
      }; # hardware.nvidia
    } # drivers
    (mkIf cfg.cuda {
      # Configure nixpkgs.
      #
      # Make sure that 'https://cache.nixos-cuda.org' is set
      # in 'nix.conf' as substituters, or you're going to cry
      # as you're rebuilding 1 ballatrillion packages.
      nixpkgs.config.cudaSupport = mkForce true;

      # Load in CUDA.
      environment.systemPackages = with pkgs; [
        cudaPackages.cudatoolkit
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
        cudaPackages.cudnn
      ];
    }) # cuda
  ]); # config
}
