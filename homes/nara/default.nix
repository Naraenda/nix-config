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

  fonts.fontconfig.enable = true;

  # fonts = {
  #   fontconfig = {
  #     enable = true;
  #     defaultFonts = {
  #       emoji = [ "Twitter Color Emoji" ];
  #     };
  #   };
  # };
  # xdg.configFile."fontconfig/conf.d/99-emoji-fix.conf".text = ''
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #   <fontconfig>

  #       <match target="pattern">
  #           <test qual="any" name="family"><string>emoji</string></test>
  #           <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #       </match>

  #       <match target="pattern">
  #           <test name="family"><string>sans</string></test>
  #           <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
  #       </match>

  #       <match target="pattern">
  #           <test name="family"><string>sans-serif</string></test>
  #           <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
  #       </match>

  #       <selectfont>
  #           <rejectfont>
  #               <pattern><patelt name="family"><string>DejaVu Sans</string></patelt></pattern>
  #           </rejectfont>
  #           <rejectfont>
  #               <pattern><patelt name="family"><string>DejaVu Serif</string></patelt></pattern>
  #           </rejectfont>
  #           <rejectfont>
  #               <pattern><patelt name="family"><string>DejaVu Sans Mono</string></patelt></pattern>
  #           </rejectfont>
  #           <rejectfont>
  #               <pattern><patelt name="family"><string>Symbola</string></patelt></pattern>
  #           </rejectfont>
  #       </selectfont>

  #   </fontconfig>
  # '';

  xdg.configFile."wireplumber/wireplumber.conf.d/50-disable-volume-control.conf".text = ''
  access.rules = [
    {
      matches = [ { application.process.binary = "Discord" } ]
      actions = { update-props = { default_permissions = "rx" } }
    }
  '';

  home = {
    packages = builtins.concatLists [
      (with pkgs; [
        # Tools
        lazygit
        ripgrep
        rsync
        less
        ffmpeg
        # System debugging
        usbutils
        pciutils
        lsof
        traceroute
        whois
        ethtool
        # Commandline
        fzf
        grc
      ])
      # Desktop
      (lib.optionals cfg.modules.desktop.enable (
        with pkgs;
        [
          # Tools
          obsidian
          qalculate-qt
          obs-studio
          firefox-bin
          libreoffice
          xwayland-satellite
          # Art
          blender
          alcom # VRChat package manager
          unityhub
          pinta
          blockbench
          krita
          # Dev
          meld # Diff tool
          remmina
          rocprof-cv
          unrar
          imagemagick
          # Media
          kew # TUI music player
          spotify
          mpv
          vlc
          yt-dlp
          # Social
          gajim # XMPP
          (discord.override {
            # withOpenASAR = true; # broken ?
            withEquicord = true;
            enableAutoscroll = true;
          })
          equibop
          element-desktop
          cinny
          # 3D printing
          prusa-slicer
          openscad
          # Fonts
          twitter-color-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          corefonts
          ipafont
        ]
      )) # cfg.modules.games.enable
      # Games
      (lib.optionals cfg.modules.games.enable (
        with pkgs;
        [
          starsector
          osu-lazer-bin
          (prismlauncher.override {
            additionalLibs = with pkgs; [
              # Required by MCEF (https://modrinth.com/mod/mcef)
              glib
              nss
              nspr
              atk
              at-spi2-atk
              libdrm
              expat
              libxkbcommon
              libgbm
              gtk3
              pango
              cairo
              alsa-lib
              dbus
              at-spi2-core
              cups
              libGL
              udev
              systemdLibs
              libxcb
              libx11
              libxcomposite
              libxdamage
              libxext
              libxfixes
              libxrandr
              libxshmfence
            ];
          })
        ]
      )) # cfg.modules.games.enable

    ]; # packages

    stateVersion = "25.05";
  }; # home

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "hydro";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;

    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Nara";
      init.defaultBranch = "develop";
      alias = {
        au = "add -u";
        fu = "! git au && git commit --amend --no-edit";
        l = "log --graph --oneline --format=format:'  %C(bold blue)%h%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
        la = "git l -all";
        p = "push";
      };
    };
  };

  programs.chromium = {
    enable =  true;
  };

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

    profiles.default.extensions = with pkgs.vscode-extensions; [
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

  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" "rust" "neocmake" ];
    userSettings = {
      base_keymap = "VSCode";
      vim_mode = false;
      autosave = "on_focus_change";
      relative_line_numbers = "enabled";

      gutter = {
        breakpoints = false;
      };
      sticky_scroll = {
        enabled = true;
      };
      minimap = {
        show = "always";
        display_in = "all_editors";
      };
      colorize_brackets = true;
      inlay_hints = {
        show_background = true;
        enabled = true;
      };
      indent_guides = {
        coloring = "indent_aware";
      };
      vim = {
        toggle_relative_line_numbers = true;
        default_mode = "insert";
      };
      auto_signature_help = true;
      show_signature_help_after_edits = true;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    }; # userSettings
  };

  programs.steam.config = {
    enable = cfg.modules.games.enable or false;

    # Close steam whenever rebuilding to ensure steam's env is up-to-date.
    closeSteam = true;

    apps = {
      vrchat = {
        id = 438100;
        # It's recommended to use custom RTSP version of Proton for VRChat
        # if you want livestreams to work.
        # Just get the tarball here:
        #   https://github.com/SpookySkeletons/proton-ge-rtsp/releases
        # For installation instruction see:
        #   https://github.com/GloriousEggroll/proton-ge-custom#native
        #
        # * rtsp18-1 is good known version.
        # * rtsp19 is broken. Do not use!
        # compatTool = "GE-Proton10-15-rtsp18-1";

        compatTool = "proton_experimental";
        launchOptions = {
          env = {
            PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES= "1";
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

  xdg.configFile."openxr/1/active_runtime.json" = {
    force = true;
    source = "${pkgs.monado-git}/share/openxr/1/openxr_monado.json";
  };
}
