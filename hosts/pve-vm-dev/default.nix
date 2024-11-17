{
  lib,
  mylib,
  myvars,
  pkgs,
  disko,
  ...
}:
#############################################################
#
#  dev - A NixOS VM running on Proxmox
#    Remote development environment
#
#############################################################
let
  hostName = "dev"; # Define your hostname.
in {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      disko.nixosModules.default
    ];

  # supported file systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  # TODO: determine if zram is useful
  # Maximum total amount of memory that can be stored in the zram swap devices (as a percentage of your total memory).
  # Defaults to 1/2 of your total RAM. Run zramctl to check how good memory is compressed.
  # This doesn’t define how much memory will be used by the zram swap devices.
  #zramSwap.memoryPercent = lib.mkForce 100;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # TODO: add any additional kernel modules and extra kernel parameters
  # boot.kernelModules = [ ];
  # boot.extraModprobeConfig = "";

  networking = {
    inherit hostName;
    # TODO: modularize networking
    #inherit (myvars.networking) defaultGateway nameservers;
    #inherit (myvars.networking.hostsInterface.${hostName}) interfaces;
    networkmanager.enable = true; # use NetworkManager for now
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}