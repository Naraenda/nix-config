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
  version = "0.4-alpha"; # Based on previous tag: 0.3

  src = fetchFromGitHub {
    repo = "xrizer";
    owner = "ImSapphire";
    rev = "363bf46ae0b1757e41a08d77bbf56631b8cfed4c";
    hash = "sha256-LeYQP1GQigzJBKJuBlYTaYLqxJAhw8Uiguf83Gcdpto=";
  }; # src
  cargoHash = "sha256-tLPwiwKkEBdsRxXgdcTM9TLJeNRZV32W11qUbyCVdHw=";

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
