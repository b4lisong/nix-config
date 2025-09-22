{lib, ...}: {
  # System builders for creating configurations
  macosSystem = import ./macosSystem.nix;
  nixosSystem = import ./nixosSystem.nix;

  # Attribute manipulation utilities
  attrs = import ./attrs.nix;

  # Use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  # scanPaths: Recursively finds all subdirectories and .nix files (except default.nix) in a given path.
  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    # Get all attribute names (files/dirs) in the directory that are either:
    (builtins.attrNames (
      lib.attrsets.filterAttrs
      # Keep if it's a directory, or a .nix file that's not default.nix
      (path: _type:
        (_type == "directory")
        || (path != "default.nix" && lib.strings.hasSuffix ".nix" path))
      (builtins.readDir path)
    ));
}
