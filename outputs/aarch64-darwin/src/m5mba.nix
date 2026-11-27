# haumea passes only the arguments named in this pattern, and `args` forwards
# them to mylib.macosSystem, so the ones unused here must still be listed.
{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
} @ args: let
  name = "m5mba";
  modules = {
    darwin-modules =
      (map mylib.relativeToRoot [
        "modules/base.nix"
        "modules/darwin"
        "hosts/darwin-${name}"
      ])
      ++ [
        {
          nixpkgs.hostPlatform = system;
          system.primaryUser = myvars.user.username;
        }
      ];
    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
    ];
  };
  systemArgs = modules // args;
in {
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
