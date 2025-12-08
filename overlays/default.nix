let
  files = builtins.readDir ./.;

  # Exclude default.nix and non-.nix files.
  nixFileFilter = name: name != "default.nix" && builtins.match ".*\\.nix" name != null;

  nixFiles = builtins.filter nixFileFilter (builtins.attrNames files);
  overlays = builtins.map (f: import (./. + "/${f}")) nixFiles;
in overlays