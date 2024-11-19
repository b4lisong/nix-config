{
  mylib,
  myvars,
  ...
}: {
  home.homeDirectory = "/Users/${myvars.username}";
  home.enableNixpkgsReleaseCheck = false; # suppress warnings
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../base/core
      ../base/tui
      ../base/gui
      ../base/home.nix
    ];
}
