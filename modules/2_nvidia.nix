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
        package = let 
          nvidiaPackages = config.boot.kernelPackages.nvidiaPackages.stable;
        in nvidiaPackages.overrideAttrs (prev: {
          open  = nvidiaPackages.open.overrideAttrs (prev: {
            patches = (prev.patch or []) ++
            (if cfg.bsbPatch then [ ../patches/nvidia/bsb-dsc-fix.patch ] else []);
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
