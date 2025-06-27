{...}: {
  imports = [
    ../../home/profiles/darwin  # Complete Darwin system (GUI + macOS-specific)
    ../../home/roles/personal
  ];

  # Host-specific customizations can go here
  # Darwin-wide kitty settings are handled in home/profiles/darwin
  
  # Example of host-specific overrides (optional):
  # programs.kitty.font.size = lib.mkForce 16;  # Override Darwin default of 14
  # programs.kitty.settings.window_padding_width = lib.mkForce 30;
}