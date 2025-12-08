{
  buildDotnetModule,
  cmake,
  config,
  copyDesktopItems,
  cudaPackages,
  dotnetCorePackages,
  enableCuda ? config.cudaSupport,
  fetchFromGitHub,
  fetchurl,
  fontconfig,
  lib,
  libGL,
  libjpeg,
  libusb1,
  libuvc,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  makeDesktopItem,
  onnxruntime,
  opencv,
  pkgsCuda,
  stdenv,
  udev,
  unzip,
  xorg,
}:
let
  trainer = fetchurl {
    url = "https://github.com/Project-Babble/BabbleTrainer/releases/download/1.3.5/BabbleTrainer-x64";
    hash = "sha256-Rxkt8OjEzlpGrmfBLJ5P3FaQHm9D8WUuje+J/x+M5sY=";
    executable = true;
  };

  calibration = fetchurl {
    url = "https://github.com/Project-Babble/BabbleCalibration/releases/download/1.0.5/Linux.zip";
    hash = "sha256-L5ssy6nLvwzpWeSMvVMZoWnmCY9uK/5LVckJmf3hGdo=";
    executable = true;
  };

  dotnet = dotnetCorePackages.dotnet_8;

  opencvsharp = stdenv.mkDerivation rec {
    pname = "opencvsharp";
    version = "4.11.0.20250507";

    src = fetchFromGitHub {
      owner = "shimat";
      repo = "opencvsharp";
      tag = version;
      hash = "sha256-CkG4Kx/AkZqyhtclMfS51a9a9R+hsqBRlM4fry32YJ0=";
    };
    buildInputs = [
      opencv
    ]
    ++ lib.optionals enableCuda [
      cudaPackages.cuda_cudart
      cudaPackages.cuda_nvcc
    ];
    nativeBuildInputs = [
      cmake
    ];
    sourceRoot = "${src.name}/src";

    cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];
  };
in
buildDotnetModule (finalAttrs: {
  version = "0.0.0";
  pname = "baballonia";

  patches = [ ./0001-disable-auto-updating.patch ];

  buildInputs = [
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

  # bsb2e_linux fork:
  # src = fetchFromGitLab {
  #   owner = "0x8081";
  #   repo = "baballonia";
  #   rev = "709982be5297c7a7f121aea89d4042519ceed495";
  #   fetchSubmodules = true;
  #   sha256 = "sha256-U9WY28FQjgtb7UXjrB2uGB0uP8b6igwxqVhzCQ/1JgY=";
  # };

  # next-v2 fork:
  src = fetchFromGitHub {
    owner = "naraenda";
    repo = "Baballonia";
    rev = "0cc8b6d9863919859828277183ea196fac6fd963";
    sha256 = "sha256-pY2ID8AOeaYptvnKuWM/YjFYgiuyWzc6U88+GRRhLcE=";
    fetchSubmodules = true;
  };

  # Don't use this.
  # src = fetchFromGitHub {
  #   owner = "Project-Babble";
  #   repo = "Baballonia";
  #   rev = "v${finalAttrs.version}";
  #   sha256 = "sha256-OnLCK/T7b0NsExKEv95a0lM9TccJkI/uLGIe+oz3Rtw=";
  #   fetchSubmodules = true;
  # };

  dotnetSdk = dotnet.sdk;
  nugetDeps = ./deps.json;
  dotnetRuntime = dotnet.runtime;
  projectFile = "src/Baballonia.Desktop/Baballonia.Desktop.csproj";

  runtimeDeps = [
    libusb1
    libuvc
    libxcb
    libxcursor
    libxi
    libxkbcommon
    opencvsharp
    udev
  ]
  ++ lib.optionals (!enableCuda) [
    onnxruntime
  ]
  ++ lib.optionals enableCuda [
    pkgsCuda.onnxruntime
  ];

  postUnpack = ''
    ln -s ${trainer}        $sourceRoot/src/Baballonia.Desktop/Calibration/Linux/Trainer/BabbleTrainer
    unzip ${calibration} -d $sourceRoot/src/Baballonia.Desktop/Calibration/Linux/Overlay
  '';

  buildType = "publish";

  postFixup = ''
    # Expose entrypoint as 'baballonia'.
    wrapDotnetProgram $out/lib/baballonia/Baballonia.Desktop $out/bin/baballonia

    # Move modules to the actual module folder.
    # Used on older commits.
    # mkdir -p $out/lib/baballonia/Modules
    # mv $out/lib/baballonia/Baballonia.{VFTCapture,OpenCVCapture,IPCameraCapture,SerialCameraCapture,LibuvcCapture}.{dll,pdb} $out/lib/baballonia/Modules/
  '';

  desktopItems = [
    (makeDesktopItem {
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
      zenisbestwolf
      ShyAssassin
    ];
  };
})
