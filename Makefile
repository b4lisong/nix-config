deploy-a2251:
	nix build .#darwinConfigurations.a2251.system \
	   --extra-experimental-features 'nix-command flakes' \
	   --impure

	./result/sw/bin/darwin-rebuild switch --flake .#a2251 --impure
