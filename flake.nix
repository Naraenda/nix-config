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
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems = {
      url = "github:nix-systems/default-linux";
      flake = false;
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
    zed-git = {
      url = "github:zed-industries/zed";
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
      allOverlays = overlays ++ [pkgsOverlay];

      mkNixpkgs = overlays: {
        inherit overlays;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
      mkPkgs = system: import nixpkgs ((mkNixpkgs [pkgsOverlay]) // { inherit system; });
      packages = forAllSystems mkPkgs;

      mkShell = module: forAllSystems (system: import module { pkgs = mkPkgs system; });

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
    in
    {
      inherit overlays allOverlays pkgsOverlay packages;

      devShells = {
        python-venv = mkShell ./shells/python-venv;
      }; # devShells

      nixosConfigurations = {
        bifrost = mkSystem "bifrost" {
          modules = {
            # Core
            nvidia = {
              enable = true;
              cuda = true;
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
        } {
          # set overrides
          # uh oh this crashess?
        }; # bifrost
        fafnir = mkSystem "fafnir" {
          modules = {
            nvidia = {
              enable = true;
              cuda = true;
            };
            podman.enable = true;
            remote.enable = true;
          };
        } { }; # fafnir
      }; # nixosConfigurations

    }; # outputs
}
