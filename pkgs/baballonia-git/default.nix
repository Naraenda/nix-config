{
  config,
  cmake,
  opencv,
  udev,
  libusb1,
  libuvc,
  libjpeg,
  libGL,
  fontconfig,
  xorg,
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fetchFromGitLab,
  copyDesktopItems,
  makeDesktopItem,
  fetchurl,
  stdenv,
  onnxruntime,
  pkgsCuda,
  cudaPackages,
  enableCuda ? config.cudaSupport,
}:
let
  internal = fetchurl {
    # This URL is weird but this is the primary source
    url = "http://217.154.52.44:7771/builds/trainer/1.0.0.0.zip";
    hash = "sha256-Amlf6OIJyiU0vdMoXAzxXPnlX4TE9hQrjDMzbkMOzDE=";
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
    ]  ++ lib.optionals enableCuda [
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
buildDotnetModule (finalAttrs: rec {
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
    udev
    libusb1
    libuvc
    opencvsharp
  ] ++ lib.optionals (!enableCuda) [
    onnxruntime
  ] ++ lib.optionals enableCuda [
    pkgsCuda.onnxruntime
  ];

  postUnpack = ''
    ln -s ${internal} $sourceRoot/src/Baballonia.Desktop/_internal.zip
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
