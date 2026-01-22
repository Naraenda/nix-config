{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.modules.vr;
in
with lib;
{
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  options.modules.vr = {
    enable = mkEnableOption "VR/XR system support";
  };

  config = mkIf cfg.enable {
    # Fix nvidia wired VR v-sync issue.
    boot.kernelParams = [ "nvidia-modeset.conceal_vrr_caps=1" ];

    environment.systemPackages = with pkgs; [
      steamcmd # Required for lighthouse calibration.
      xrizer-git # SteamVR to OpenXR translation.
      # wlx-overlay-s # Overlay & playspace mover.
      wayvr # Overlay & playspace mover.
      vrcft-avalonia # Facial data proxy.
      baballonia-git # Eye & face tracking.
    ];

    # OpenXR runtime.
    services.monado = {
      enable = true;
      # package = pkgs.monado-git;
      defaultRuntime = true; # Register as default OpenXR runtime.
      forceDefaultRuntime = true; # Register as default OpenXR runtime.
      highPriority = true;
    };

    # Monado configuration for nvidia + wired VR.
    systemd.user.services.monado.environment = {
      WMR_HANDTRACKING = "0";
      STEAMVR_LH_ENABLE = "1";
      # Set VR display mode.
      # For Bigscreen Beyond use 0 (72Hz) or 1 (90Hz).
      XRT_COMPOSITOR_DESIRED_MODE = "0";
      # Enable async reprojection (i think).
      XRT_COMPOSITOR_COMPUTE = "1";
      # Fix tracking latency, no clue how lol:
      XRT_COMPOSITOR_USE_PRESENT_WAIT = "1";
      # XRT_COMPOSITOR_FORCE_NVIDIA_DISPLAY="NVIDIA";
      # Allow larger overhead of compositor timewarp
      U_PACING_COMP_TIME_FRACTION_PERCENT = "50"; # Used to be 90,
      # Allow floating FPS
      U_PACING_COMP_MIN_FRAME_PERIOD = "1";
      U_PACING_APP_IMMEDIATE_WAIT_FRAME_RETURN = "0";
    };

    # Bigscreen Beyond & Vive Face tracker.
    services.udev.extraRules = ''
      # Bigscreen Beyond
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0101", MODE="0660", TAG+="uaccess", GROUP="video"
      # Bigscreen Bigeye
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0202", MODE="0660", TAG+="uaccess", GROUP="video", SYMLINK+="video-bigeye0"
      # Bigscreen Beyond Audio Strap
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="0105", MODE="0660", TAG+="uaccess", GROUP="video"
      # Bigscreen Beyond Firmware Mode?
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="35bd", ATTRS{idProduct}=="4004", MODE="0660", TAG+="uaccess", GROUP="video"
      # HTC Vive Face Tracker (not sure if required)
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="0321", MODE="0660", TAG+="uaccess", GROUP="video", SYMLINK+="video-htcft0"
    ''; # services.udev.extraRules
  };
}
