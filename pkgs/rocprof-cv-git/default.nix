{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  pkg-config,
  qt5,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rocprof-compute-viewer";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocprof-compute-viewer";
    rev = "4bcf2d6c8424c36216bb68ab9878fea1ef3daf9c";
    hash = "sha256-C/r5P5xtO+n4K0+WWXDcNXLQyoJoT5DbUhWrHNadd6U="; 
  };

  nativeBuildInputs = [
    cmake
    doxygen
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
  ];

  cmakeFlags = [
    "-DQT_VERSION_MAJOR=5"
  ];

  # Add this block to your derivation
  installPhase = ''
    runHook preInstall
    install -Dm755 rocprof-compute-viewer $out/bin/rocprof-compute-viewer
    runHook postInstall
  '';

  meta = with lib; {
    description = "A visualizer for ROCm profiler compute traces";
    homepage = "https://github.com/ROCm/rocprof-compute-viewer";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "rocprof-compute-viewer";
  };
})
