{
  lib,
  inputs,
  ...
}@args:
let
  inherit (inputs) haumea;

  # Auto-discover all host files in src/
  # Each file in src/ will be imported and passed 'args'
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  # Remove the file paths, keeping only the values
  dataWithoutPaths = builtins.attrValues data;

  # Merge all discovered hosts into a single attrset
  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.nixosConfigurations or { }) dataWithoutPaths
    );
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths);
  };
in
outputs // {
  inherit data; # for debugging - allows inspecting what haumea loaded

  # Add eval tests support (optional, can be added later)
  evalTests = haumea.lib.loadEvalTests {
    src = ./tests;
    inputs = args // { inherit outputs; };
  };
}