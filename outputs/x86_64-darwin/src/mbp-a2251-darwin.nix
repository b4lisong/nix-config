{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
} @ args: let
  name = "a2251";

  modules = {
    darwin-modules =
      (map mylib.relativeToRoot [
        # common
        # TODO: add secrets
        #"secrets/darwin.nix"
        "modules/darwin"
        # host-specific
        "hosts/mbp-${name}-darwin"
        "hosts/mbp-${name}-darwin/apps.nix" # host-specific apps
      ])
      ++ [];

    home-modules = map mylib.relativeToRoot [
      "hosts/mbp-${name}-darwin/home.nix"
      "home/darwin"
    ];
  };

  systemArgs = modules // args;
in {
  # macOS's configuration
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
