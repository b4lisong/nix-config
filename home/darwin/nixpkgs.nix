{...}: {
  # suppress allowUnfree warning when building with nix-build
  home.file.".config/nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
