# Attribute set manipulation utilities used throughout the configuration
{lib, ...}: {
  # These are used by outputs/default.nix to merge host configurations
  # Key is mergeAttrsList - used by our outputs system to combine multiple host
  #   configurations into one attribute set.
  inherit (lib.attrsets) mapAttrs mapAttrs' mergeAttrsList foldlAttrs;

  # Additional helper for list to attrs conversion
  listToAttrs = lib.genAttrs; # Generates attribute set from a list
}
