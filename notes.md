1. curl -fsSL https://install.determinate.systems/nix | sh -s -- install
  - Choose 'no' when prompted to install the Determinate distribution to installthe recommended vanilla upstream Nix.
2. nix flake init -t nix-darwin/nix-darwin-25.05
3. sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
4. Set nixpkgs.hostPlatform = "x86_64-darwin";
5. sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .
6. sudo darwin-rebuild switch --flake .
