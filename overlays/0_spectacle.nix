final: prev: {
  kdePackages = prev.kdePackages // {
    spectacle = prev.kdePackages.spectacle.overrideAttrs (
      finalAttrs: prevAttrs: {
        postFixup = (prevAttrs.postFixup or "") + ''
          wrapProgram $out/bin/spectacle \
            --set LIBVA_DRIVER_NAME ""
        '';
      }
    );
  };
}
