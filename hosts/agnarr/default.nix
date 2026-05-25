{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "agnarr";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  time.timeZone = "Europe/Amsterdam";

  # Allow real time priority thread scheduling.
  security.rtkit.enable = true;

  # Users (me).
  users.users.nara = {
    isNormalUser = true;
    description = "Nara";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
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
  nix.settings.trusted-users = [ "root" "nara" ];

  # enable the ydotool service
  programs.ydotool = {
    enable = true;
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
  system.stateVersion = "25.11";
}
