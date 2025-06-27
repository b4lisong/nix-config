{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    ## Stable packages
    neovim

    ## Unstable packages
    pkgs-unstable.nodePackages_latest.nodejs # latest Node.js
    pkgs-unstable.claude-code # latest Claude Code (npm)
  ];
}
