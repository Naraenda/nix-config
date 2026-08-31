{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  kernel = pkgs.cachyosKernels.linux-cachyos-latest.override {
    pname = "linux-cachyos-custom";

    patches = [
      ../../patches/kernel/bsb-uvc-version-fix.patch
    ];

    # Optimization settings
    cpusched = "eevdf";
    lto = "thin";
    processorOpt = "zen4";
    hzTicks = "1000";
  };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "bifrost";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  time.timeZone = "Europe/Amsterdam";

  # boot.kernelParams = [
  #   "amd_pstate=guided"
  #   "preempt=full"
  #   "threadirqs"
  # ];

  boot.kernelPackages = let
    helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" {};
  in helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);

  # Not required with CachyOS-based kernel since we patch directly there!
  # boot.kernelPatches = [
  #   {
  #     name = "bsb-uvc-version-fix";
  #     patch = ../../patches/kernel/bsb-uvc-version-fix.patch;
  #   }
  # ];

  # Allow swapping scheduler.
  # Not required with BORE or BMQ scheduler!
  # services.scx = {
  #   enable = true;
  #   # Latency-Aware Virtual Deadline
  #   scheduler = "scx_lavd";
  #   extraArgs = [ "--performance" ];
  # };

  # powerManagement = {
  #   cpuFreqGovernor = "performance";
  # };

  # Allow real time priority thread scheduling.
  security.rtkit.enable = true;

  # Users (me).
  users.users.nara = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "render"
      "ydotool"
    ];
  };
  home-manager.users.nara = import ../../homes/nara {
    inherit
      inputs
      lib
      pkgs
      config
      ;
  };
  nix.settings.trusted-users = [
    "root"
    "nara"
  ];

  # enable the ydotool service
  programs.ydotool = {
    enable = true;
  };

  fileSystems =
    let
      ntfsOptions = [
        "rw"
        "uid=1000"
        "gid=100"
        "umask=0022"
        "nofail"
      ];
      btrfsOptions = [
        "nofail"
        "compress=zstd"
      ];
    in
    {
      "/mnt/axiom" = {
        device = "/dev/disk/by-label/Axiom";
        fsType = "btrfs";
        options = btrfsOptions;
      };
      "/mnt/daedalus" = {
        device = "/dev/disk/by-label/Daedalus";
        fsType = "ntfs-3g";
        options = ntfsOptions;
      };
      "/mnt/elysium" = {
        device = "/dev/disk/by-label/Elysium";
        fsType = "ntfs-3g";
        options = ntfsOptions;
      };
      "/run/media/nara/friede" = {
        device = "/dev/disk/by-label/Friede";
        fsType = "ntfs-3g";
        options = ntfsOptions;
      };
    };

  hardware.graphics = {
    enable = true;
  };

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  # Audio services.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # Mount drives automagically.
  services.udisks2 = {
    enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # No touchy >:(
  system.stateVersion = "25.05";
}
