# This file extends the nixpkgs standard library and contains module helper functions.
#
# scanPaths scans a directory path and returns a list of paths to:
#   - all subdirectories
#   - all `.nix` files (except `default.nix`)
# This makes it easier to add new modules without manually updating import lists.
# Copied from https://raw.githubusercontent.com/ryan4yin/nix-config/refs/heads/main/lib/default.nix
{lib, ...}: {
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
