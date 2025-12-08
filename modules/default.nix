{
  ...
}:
let
  files = builtins.readDir ./.;

  # Exclude default.nix and non-.nix files.
  nixFileFilter = name: name != "default.nix" && builtins.match ".*\\.nix" name != null;

  nixFiles = builtins.filter nixFileFilter (builtins.attrNames files);
  imports = builtins.map (f: ./. + "/${f}") nixFiles;
in
{
  inherit imports;
}
