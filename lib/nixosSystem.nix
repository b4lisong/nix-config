{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  home-modules ? [],
  specialArgs ? (genSpecialArgs system),
  myvars,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ [
        (_: {
          nixpkgs.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ]
      # Check if we have any home modules;
      # if true: include the modules
      # if false: include nothing
      # Home Manager only activated if we actually have
      # home configuration
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            # Use system nixpkgs
            useGlobalPkgs = true;
            # Install to user profile
            useUserPackages = true;
            # Backup conflicts
            backupFileExtension = "home-manager.backup";
            # Pass our variables to HM
            extraSpecialArgs = specialArgs;
            # User config
            users."${myvars.user.username}".imports = home-modules;
          };
        }
      ]);
  }
