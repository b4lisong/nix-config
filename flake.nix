{
  description = "Modular nix-darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
    let
      lib = import ./lib/modules.nix { inherit (nixpkgs) lib; };
      vars = import ./variables;
      mkDarwinHost = hostName: {
        modules = [
          ./modules/base.nix
          ./modules/darwin
          ./hosts/${hostName}/system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.${vars.user.username}.imports = [
              ./hosts/${hostName}/home.nix
            ];
          }
        ];
      };
      systems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      nixpkgsFor = system: nixpkgs.legacyPackages.${system};
      mkDevShell = system:
        let pkgs = nixpkgsFor system;
        in pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt statix deadnix nix-tree manix nil jq git
          ];
        };
    in {
      darwinConfigurations.${vars.hosts.a2251.hostname} =
        nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.a2251.hostname);
      devShells = forAllSystems (system: { default = mkDevShell system; });
    };
}
