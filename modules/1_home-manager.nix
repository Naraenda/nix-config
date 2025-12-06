{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: with lib; {
  # TODO: figure out if we can simply pass module config
  # to home manager. Because then we can enable/disable
  # parts if certain system modules are available or not.
  imports = [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
    }
  ];
}
