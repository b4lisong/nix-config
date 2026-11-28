{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = ["ehci_pci" "ahci" "ata_piix" "uhci_hcd" "xhci_pci_renesas" "usbhid" "usb_storage" "sd_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0-part1";
      fsType = "ext4";
    };
    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };
    "/incus" = {
      device = "rpool/incus";
      fsType = "zfs";
    };
    "/mnt/app_config" = {
      device = "storage/app_config";
      fsType = "zfs";
      options = ["defaults" "nofail"];
    };
    "/mnt/backup" = {
      device = "storage/backup";
      fsType = "zfs";
      options = ["defaults" "nofail"];
    };
    "/mnt/media" = {
      device = "storage/media";
      fsType = "zfs";
      options = ["defaults" "nofail"];
    };
    "/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
    };
    "/var" = {
      device = "rpool/var";
      fsType = "zfs";
    };
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
