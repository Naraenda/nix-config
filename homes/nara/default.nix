{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.steam-config-nix.homeModules.default
  ];

  home = {
    # TODO: check if we can toggle these based
    # on enabled/disabled modules.
    packages = with pkgs; [
      # Tools      #
      obsidian     # Note taking
      qalculate-qt # Calculator
      # Dev        #
      vscode-fhs   # Microcrap
      meld         # Diff tool w/regex support
      # Web        #
      firefox      # There's no good browser
      # Music      #
      kew          # TUI music player
      spotify      # Spotify (not cool)
      # Social     #
      gajim        # XMPP
      vesktop      # Discord
      # Games      #
      (starsector.overrideAttrs ({ ... }: {
        postInstall = ''
          cp ${../../dotfiles/starsector/settings.json} $out/share/starsector/data/config/settings.json
        ''; # postInstall
        } # overrideAttrs
      )) # starsector
    ]; # packages

    stateVersion = "25.05";
  }; # home

  programs.vscode = {
    package = pkgs.vscode.fhsWithPackages (ps:
      with ps; [
        # nix specific
        nixfmt
        nixd
        direnv
        # misc.
        rustup
        zlib
        openssl.dev
        pkg-config
      ]
    ); # package
  }; # programs.vscode

  programs.steam.config = {
    enable = true;

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
