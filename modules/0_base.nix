{
  lib,
  pkgs,
  ...
}:
with lib;
{
  # TODO: add option to swap between different kernel packages.
  # TODO: add option to mix-in patches.

  config = {
    boot = {
      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 8;
        efi.canTouchEfiVariables = true;
      };

      tmp.cleanOnBoot = true;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_6_18;
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos-cuda.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };

    programs.git = {
      enable = true;
      lfs.enable = true;
    };

    programs.ssh = {
      startAgent = true;
      enableAskPassword = true;
    };

    programs.nix-ld = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      btop
      git
      hyfetch
      nano
      screen
      tmux
      vim
      wget
      # Nix-tooling
      nixd # LSP
      nil # LSP
      statix # linter
      alejandra # formatter
      deadnix # deadcode finder
      nixfmt-rfc-style # formatter
      nom # output monitor
      nix-index # package lookup
    ];

    fonts.fontDir.enable = true;
    fonts.enableDefaultPackages = true;
    fonts.fontconfig.useEmbeddedBitmaps = true;
    fonts.packages = with pkgs; [
      dejavu_fonts
      twitter-color-emoji
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      corefonts
      ipafont
      fira-code
      fira-code-symbols
    ];
  };
}
