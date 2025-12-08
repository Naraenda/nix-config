{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config;
in
{
  imports = [
    inputs.steam-config-nix.homeModules.default
  ];

  home = {
    packages = builtins.concatLists [
      (with pkgs; [
        ripgrep
      ])
      # Desktop
      (lib.optionals cfg.modules.desktop.enable (
        with pkgs;
        [
          # Tools
          obsidian
          qalculate-qt
          # Game-dev
          blender
          alcom # VRChat package manager
          unityhub
          # Dev
          meld # Diff tool
          # Web
          firefox
          # Music
          kew # TUI music player
          spotify
          # Social
          gajim # XMPP
          vesktop # Discord
        ]
      )) # cfg.modules.games.enable
      # Games
      (lib.optionals cfg.modules.games.enable (
        with pkgs;
        [
          starsector
        ]
      )) # cfg.modules.games.enable

    ]; # packages

    stateVersion = "25.05";
  }; # home

  programs.vscode = {
    enable = cfg.modules.desktop.enable or false;

    package = pkgs.vscode.fhsWithPackages (
      pkgs: with pkgs; [
        # nix specific
        direnv
        nixd
        nixfmt
        nixfmt-tree
        # misc.
        openssl.dev
        pkg-config
        zlib
      ]
    ); # package

    extensions = with pkgs.vscode-extensions; [
      # dev
      ms-vscode-remote.vscode-remote-extensionpack
      ms-vsliveshare.vsliveshare
      # nix
      jnoortheen.nix-ide
      # c++
      ms-vscode.cpptools-extension-pack
      llvm-vs-code-extensions.vscode-clangd
    ]; # extensions
  }; # programs.vscode

  programs.steam.config = {
    enable = cfg.modules.games.enable or false;

    # Close steam whenever rebuilding to ensure steam's env is up-to-date.
    closeSteam = true;

    apps = {
      vrchat = {
        id = 438100;
        # It's recommended to use custom RTSP version of Proton for VRChat.
        # Just get the tarball here:
        #   https://github.com/SpookySkeletons/proton-ge-rtsp/releases
        # For installation instruction see:
        #   https://github.com/GloriousEggroll/proton-ge-custom#native
        #
        # * rtsp18-1 is good known version.
        # * rtsp19 is broken. Do not use!
        compatTool = "GE-Proton10-15-rtsp18-1";
        launchOptions = {
          env = {
            PRESSURE_VESSEL_FILESYSTEMS_RW = "$XDG_RUNTIME_DIR/monado_comp_ipc";
          }; # env
        }; # launchOptions
      }; # vrchat
    }; # apps
  }; # programs.steam.config

  xdg.configFile."openvr/openvrpaths.vrpath" = {
    force = true;
    text = ''
      {
        "config" :
        [
          "~/.local/share/Steam/config"
        ],
        "external_drivers" : null,
        "jsonid" : "vrpathreg",
        "log" :
        [
          "~/.local/share/Steam/logs"
        ],
        "runtime" :
        [
          "${pkgs.xrizer-git}/lib/xrizer"
        ],
        "version" : 1
      }
    ''; # text
  }; # xdg.configFile."openvr/openvrpaths.vrpath"
}
