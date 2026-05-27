{
  description = "Meow :3";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    # TODO: I kinda want to build all VR/XR packages
    # out-of-tree, because bleeding edge is desired.
    #
    # Still need to do the following projects:
    # * wlx-overlay-s (https://github.com/galister/wlx-overlay-s)
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
    };
    # dot-files and user stuff
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # utils
    systems = {
      url = "github:nix-systems/default-linux";
      flake = false;
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
    # programs
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
    zed-git = {
      url = "github:zed-industries/zed";
    };
    blender-bin = {
      url = "https://flakehub.com/f/edolstra/blender-bin/*";
    };
  }; # inputs

  outputs =
    {
      systems,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs (import systems);

      overlays = import ./overlays;
      pkgsOverlay = (self: super: import ./pkgs { pkgs = super; config = super.config; }); # TODO: move overlay definition to pkgs/default.nix
      allOverlays = overlays ++ [
        pkgsOverlay
        inputs.nix-cachyos-kernel.overlays.default
      ];

      mkNixpkgs = overlays: {
        inherit overlays;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
      mkPkgs = system: import nixpkgs ((mkNixpkgs [pkgsOverlay]) // { inherit system; });

      mkShell = module: system: import module { pkgs = mkPkgs system; };

      mkSystem =
        host: config: overrides:
        let
          default = {
            system = "x86_64-linux";
          };
          configured = {
            modules = [
              { nixpkgs = mkNixpkgs allOverlays; }
              ./modules
              ./hosts/${host}
              config
            ]; # modules
            specialArgs.inputs = inputs;
          };
        in
        lib.nixosSystem (lib.attrsets.mergeAttrsList [
          default
          configured
          overrides
        ]); # mkSystem

      packages = forAllSystems mkPkgs;
    in
    {
      inherit overlays allOverlays pkgsOverlay packages;

      devShells = forAllSystems (system: {
        python-venv = mkShell ./shells/python-venv system;
      }); # devShells

      nixosConfigurations = {
        bifrost = mkSystem "bifrost" {
          modules = {
            # Core
            nvidia = {
              enable = true;
              cuda = true;
              bsbPatch = true;
            };
            dist-build.enable = true;
            desktop.enable = true;
            # Extra
            games.enable = true;
            vr.enable = true;
          }; # modules
          nix.settings.system-features = [
            "gccarch-znver5"
          ];
        } { }; # bifrost
        agnarr = mkSystem "agnarr" {
          modules = {
            # Core
            nvidia = {
              enable = true;
              cuda = false;
            };
            desktop.enable = true;
            # Extra
            games.enable = true;
          }; # modules
        } { }; # agnarr
      }; # nixosConfigurations

    }; # outputs
}
