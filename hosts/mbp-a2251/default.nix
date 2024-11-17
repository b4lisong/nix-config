{
  nixos-hardware,
  myvars,
  ...
}:
#############################################################
#
#  a2251 - NixOS running on Macbook Pro 2020 I5 16G
#   https://github.com/NixOS/nixos-hardware/tree/master/apple/t2
#
#############################################################
let
  hostName = "a2251"; # Define your hostname.
in {
  imports = [
    nixos-hardware.nixosModules.apple-t2
    ./apple-set-os-loader.nix
    {hardware.myapple-t2.enableAppleSetOsLoader = true;}

    ./hardware-configuration.nix
    # putting impermanence config here instead
    ./impermanence.nix
    # audio fix; source: https://wiki.t2linux.org/guides/audio-config/
    ./t2-better-audio.nix
  ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";

  networking = {
    inherit hostName;

    # configures the network interface(include wireless) via `nmcli` & `nmtui`
    networkmanager.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
