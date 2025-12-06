{ 
  appimageTools, 
  fetchurl,
  makeDesktopItem,
}: let
  # I would build this from source, but something is
  # terribly wrong with how they configured nuget.
  # It's a pain to fix that so isntead we're just
  # wrapping the appimage.

  pname = "vrcft-avalonia";
  version = "1.1.1.0";
  src = fetchurl {
    url  = "https://github.com/dfgHiatus/VRCFaceTracking.Avalonia/releases/download/v${version}/VRCFaceTracking.Avalonia.${version}.AppImage";
    hash = "sha256-oW8tsrJfC8woL2rCVyItFk4oR8M1SlQ/Y0vA1EaOhGQ=";
  }; # src
  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "VRCFaceTracking Avalonia";
    exec = pname;
    terminal = false;
    categories = [ "Game" ];
  }; # desktopItem
in appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ 
    pkgs.icu 
  ]; # extraPkgs

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
  ''; # extraInstallCommands
}
