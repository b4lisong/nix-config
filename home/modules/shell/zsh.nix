{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      # zoxide aliases
      cd = "z"; # replace cd with z
      cdi = "zi"; # interactive selection
      cdr = "z -"; # go to previous directory
      cdf = "z -f"; # force directory change
      cdh = "z ~"; # go to home directory
    };
  };
}
