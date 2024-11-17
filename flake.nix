# glory to ryan4yin/nix-config
{
  # one config to rule them all
  description = "b4lisong's nixos empire";

  outputs = inputs: import ./outputs inputs;

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's unstable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    #TODO: implement lanzaboote for secure boot

    # impermanence
    impermanence.url = "github:nix-community/impermanence";
    
    # TODO: enable macos support
    ## for macos
    #nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    #nix-darwin = {
    #  url = "github:lnl7/nix-darwin";
    #  inputs.nixpkgs.follows = "nixpkgs-darwin";
    #};
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.05";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix secrets management
    agenix = {
      # using original agenix for now
      ## lock with git commit at 0.15.0
      ## url = "github:ryantm/agenix/564595d0ad4be7277e07fa63b5a991b3c645655d";
      ## replaced with a type-safe reimplementation to get a better error message and less bugs.
      #url = "github:ryan4yin/ragenix";
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.6.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # add git hooks to format nix code before commit
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: enable nuenv later
    #nuenv.url = "github:DeterminateSystems/nuenv";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: enable nixpak later
    #nixpak = {
    #  url = "github:nixpak/nixpak";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    ########################  Some non-flake repositories  #########################################

    # TODO: enable polybar-themes later
    #polybar-themes = {
    #  url = "github:adi1090x/polybar-themes";
    #  flake = false;
    #};

    ########################  My own repositories  #########################################

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    # TODO: enable mysecrets later
    #mysecrets = {
    #  url = "git+ssh://git@github.com/b4lisong/nix-secrets.git?shallow=1";
    #  flake = false;
    #};

    # TODO: enable wallpapers later
    ## my wallpapers
    #wallpapers = {
    #  url = "github:ryan4yin/wallpapers";
    #  flake = false;
    #};

    # TODO: enable nur later?
    #nur-ryan4yin.url = "github:ryan4yin/nur-packages";
    #nur-ataraxiasjel.url = "github:AtaraxiaSjel/nur";
  };
}
