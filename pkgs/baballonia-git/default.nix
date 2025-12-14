{
  config,
  pkgs,
  lib,
  enableCuda ? config.cudaSupport,
  ...
}:
let
  babbleTrainer = pkgs.callPackage ./babble-trainer.nix { inherit enableCuda; };

  # TODO: figure out how to build & run Godot OpenXR projects.
  calibZip = pkgs.fetchurl {
    url = "https://github.com/Project-Babble/BabbleCalibration/releases/download/1.0.5/Linux.zip";
    hash = "sha256-L5ssy6nLvwzpWeSMvVMZoWnmCY9uK/5LVckJmf3hGdo=";
    executable = true;
  };

  dotnet = pkgs.dotnetCorePackages.dotnet_8;

  opencvsharp = pkgs.stdenv.mkDerivation rec {
    pname = "opencvsharp";
    version = "4.11.0.20250507";

    src = pkgs.fetchFromGitHub {
      owner = "shimat";
      repo = "opencvsharp";
      tag = version;
      hash = "sha256-CkG4Kx/AkZqyhtclMfS51a9a9R+hsqBRlM4fry32YJ0=";
    };

    buildInputs = [
      pkgs.opencv
    ]
    ++ lib.optionals enableCuda [
      pkgs.cudaPackages.cudatoolkit
    ];

    nativeBuildInputs = [
      pkgs.cmake
    ];

    sourceRoot = "${src.name}/src";

    cmakeFlags = [
      (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
      "-DCUDAToolkit_ROOT=${pkgs.cudaPackages.cudatoolkit}"
    ];
  };
  inPureEvalMode = !builtins ? currentSystem;
in
pkgs.buildDotnetModule (finalAttrs: {
  version = "0.0.0";
  pname = "baballonia";

  buildInputs = with pkgs; [
    cmake
    copyDesktopItems
    fontconfig
    libGL
    libjpeg
    libusb1
    libuvc
    opencv
    opencvsharp
    udev
    unzip
    xorg.libICE
    xorg.libSM
    xorg.libX11
  ];

  # https://github.com/Naraenda/Baballonia/tree/next-v3
  # - bsb2e camera through libuvc
  # - vft fix
  # - packaging fix for nix
  # - no micros*ft onnxruntime
  src =
    if inPureEvalMode then
      pkgs.fetchFromGitHub {
        owner = "naraenda";
        repo = "Baballonia";
        rev = "a8c813e267c26f51f1d62bf0c8ba687ef92c618b";
        sha256 = "sha256-H5W+QsvccLOKzqqDIp7Xio5DZlUbRkT5HB4I66NBDhE=";
        fetchSubmodules = true;
      }
    else
      /home/nara/code/Baballonia;

  dotnetSdk = dotnet.sdk;
  nugetDeps = ./deps.json;
  dotnetRuntime = dotnet.runtime;
  projectFile = "src/Baballonia.Desktop/Baballonia.Desktop.csproj";

  runtimeDeps =
    with pkgs;
    [
      libusb1
      libuvc
      libxcb
      libxcursor
      libxext
      libxi
      libxkbcommon
      opencvsharp
      udev
      libGL
    ]
    ++ lib.optionals (!enableCuda) [
      onnxruntime
    ]
    ++ lib.optionals enableCuda [
      pkgsCuda.onnxruntime
    ];

  postUnpack = ''
    ln -s ${babbleTrainer}/bin/BabbleTrainer $sourceRoot/src/Baballonia.Desktop/Calibration/Linux/Trainer/BabbleTrainer

    unzip ${calibZip} -d $sourceRoot/src/Baballonia.Desktop/Calibration/Linux/Overlay
  '';

  buildType = "publish";

  postFixup =
    let
      calibTool = "$out/lib/baballonia/Calibration/Linux/Overlay/BabbleCalibration.x86_64";
    in
    ''
      # Re-export as 'baballonia'.
      wrapDotnetProgram $out/lib/baballonia/Baballonia.Desktop $out/bin/baballonia

      # Godot applications requires steam-run for whatever reason.
      # I'm too lazy to figure out what part of the FSH it needs.
      # https://nixos.wiki/wiki/Godot

      # Create a backup of the original
      mv ${calibTool} ${calibTool}-original
      # Wrap the original
      makeWrapper ${pkgs.steam-run}/bin/steam-run \
        ${calibTool} \
        --add-flags ${calibTool}-original \
        --add-flags --xr-mode \
        --add-flags on \
        --set XR_LOADER_DEBUG all \
        --set BABBLE_TRAINER_TMP_DIR /tmp
      # Overwrite the version in bin
      rm $out/bin/BabbleCalibration.x86_64
      ln -s ${calibTool} $out/bin/BabbleCalibration.x86_64
    '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "Baballonia";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %u";
      terminal = false;
      type = "Application";
      icon = "baballonia";
      categories = [ "Game" ];
    })
  ];

  meta = {
    mainProgram = "baballonia";
    platforms = lib.platforms.linux;
    homepage = "https://github.com/Project-Babble/Baballonia";
    description = "Free and open source eye and face tracking for social VR";
    maintainers = with lib.maintainers; [
      naraenda
    ];
  };
})
