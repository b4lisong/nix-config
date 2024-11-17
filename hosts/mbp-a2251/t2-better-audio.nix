{
  config,
  pkgs,
  lib,
  ...
}: let
  # Import the custom PipeWire configuration package
  appleT2PipewireConfig = import ./apple-t2-pipewire-config.nix {inherit (pkgs) stdenv lib;};
in {
  # Enable PipeWire and include the custom configuration package
  services.pipewire = {
    configPackages = [appleT2PipewireConfig];
  };

  # Include your custom udev rules
  services.udev.extraRules = ''
    SUBSYSTEM!="sound", GOTO="pulseaudio_end"
    ACTION!="change", GOTO="pulseaudio_end"
    KERNEL!="card*", GOTO="pulseaudio_end"

    SUBSYSTEMS=="pci", ATTRS{vendor}=="0x106b", ATTRS{device}=="0x1803", PROGRAM="/run/current-system/sw/bin/sed -n 's/.*AppleT2x\\([0-9]\\).*/\\1/p' /proc/asound/cards", ENV{PULSE_PROFILE_SET}="apple-t2x%c.conf", ENV{ACP_PROFILE_SET}="apple-t2x%c.conf"

    LABEL="pulseaudio_end"
  '';
}
