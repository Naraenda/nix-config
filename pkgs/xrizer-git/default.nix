{
  fetchFromGitHub,
  lib,
  libGL,
  libxkbcommon,
  nix-update-script,
  openxr-loader,
  pkg-config,
  rustPlatform,
  shaderc,
  vulkan-loader,
  stdenv,
  cmake,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "xrizer";
  version = "0.5-alpha"; # Based on previous tag: 0.3

  src = fetchFromGitHub {
    repo = "xrizer";
    owner = "ImSapphire";
    # Cutting edge from https://github.com/ImSapphire/xrizer/tree/next
    rev = "c87d7c38fbc372980ca226802a524c1d6d85403e";
    hash = "sha256-PEypy9lOcL8Nbc11YYgXNhkoBEyJVStVGs+tozcumeY=";
  }; # src
  cargoHash = "sha256-orfK5pwWv91hA7Ra3Kk+isFTR+qMHSZ0EYZTVbf0fO0=";

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
    shaderc
  ];

  buildInputs = [
    libxkbcommon
    vulkan-loader
    openxr-loader
  ];

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'features = ["static"]' 'features = ["linked"]'
    substituteInPlace src/graphics_backends/gl.rs \
      --replace-fail 'libGLX.so.0' '${lib.getLib libGL}/lib/libGLX.so.0'
    export CMAKE=${cmake}/bin/cmake
  '';

  postInstall = ''
    mkdir -p $out/lib/xrizer/$platformPath
    ln -s "$out/lib/libxrizer.so" "$out/lib/xrizer/$platformPath/vrclient.so"
  '';

  platformPath =
    {
      "aarch64-linux" = "bin/linuxarm64";
      "i686-linux" = "bin";
      "x86_64-linux" = "bin/linux64";
    }
    ."${stdenv.hostPlatform.system}";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "XR-ize your favorite OpenVR games";
    homepage = "https://github.com/Supreeeme/xrizer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];
  };
}
