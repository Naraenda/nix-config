self: super: {
  starsector = super.starsector.overrideAttrs {
    postInstall = ''
      cp ${../dotfiles/starsector/settings.json} $out/share/starsector/data/config/settings.json
    ''; # postInstall
  }; # starsector
}
