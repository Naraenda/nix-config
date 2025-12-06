{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  opencv,
  cudaPackages,
  enableCuda ? config.cudaSupport,
}:
stdenv.mkDerivation rec {
  name = "opencvsharp";
  src = fetchFromGitHub {
    owner = "shimat";
    repo = "opencvsharp";
    tag = "4.11.0.20250507";
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
  cmakeFlags = [ 
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  meta = with lib; {
    license = licenses.asl20;
    platforms = platforms.unix;
    description = "OpenCV wrapper for .NET";
    homepage = "https://github.com/shimat/opencvsharp";
  };
}
