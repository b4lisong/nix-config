{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid"];
    initrd.kernelModules = [];
    kernelModules = [];
    extraModulePackages = [];
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
