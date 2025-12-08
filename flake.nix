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

      overlays = [
        (final: prev: import ./pkgs { pkgs = final; })
      ]; # overlays

      nixpkgsConfig = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      }; # nixpkgsConfig

      mkPkgs =
        system:
        import nixpkgs {
          inherit system overlays;
          nixpkgs.config = nixpkgsConfig;
        }; # mkPkgs

      mkShell = module: forAllSystems (system: import module { pkgs = mkPkgs system; }); # mkShell

      mkSystem =
        host: base: config:
        lib.nixosSystem (
          lib.mkMerge [
            base
            {
              modules = [
                { nixpkgs = { inherit overlays; }; }
                { nixpkgs.config = nixpkgsConfig; }
                ./modules
                ./hosts/${host}
                config
              ]; # modules
              specialArgs.inputs = inputs;
            }
          ]
        ); # mkSystem
    in
    {
      packages = forAllSystems mkPkgs;

      devShells = {
        python-venv = mkShell ./shells/python-venv;
      }; # devShells

      nixosConfigurations = {
        bifrost =
          mkSystem "bifrost"
            {
              system = "x86_64-linux";
            }
            {
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
            }; # bifrost
      }; # nixosConfigurations

    }; # outputs
}
