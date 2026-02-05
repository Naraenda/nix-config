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
  };
  config = mkIf cfg.enable (mkMerge [
    {
      services.xserver.videoDrivers = [
        "nvidia"
      ];

      # Configure GPU drivers.
      hardware.nvidia = {
        modesetting.enable = true;

        # Unused, but maybe set it?
        powerManagement.enable = false;
        powerManagement.finegrained = false;

        # Open kernel modules are required for wired VR.
        # https://lvra.gitlab.io/docs/hardware/
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable // {
          # https://github.com/NixOS/nixpkgs/issues/467145
          open = config.boot.kernelPackages.nvidiaPackages.stable.open.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [
              # (pkgs.fetchpatch {
              #   name = "get_dev_pagemap.patch";
              #   url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
              #   hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
              # }) # pkgs.fetchpatch
            ]; # patches
          }); # open
        }; # package
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
