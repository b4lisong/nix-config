{ pkgs, ... }:
{
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
    };
  };
} 