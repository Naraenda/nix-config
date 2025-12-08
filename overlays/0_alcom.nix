self: super: {
  alcom = super.alcom.overrideAttrs (old: {
    postInstall = old.postInstall or "" + ''
      wrapProgram $out/bin/ALCOM --set WEBKIT_DISABLE_DMABUF_RENDERER 1
    '';
  }); # alcom
}
