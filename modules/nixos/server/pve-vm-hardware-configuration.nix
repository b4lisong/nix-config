{
  modulesPath,
  lib,
  ...
}:
##############################################################################
#
#  Template for PVE VM, mainly based on:
#    ryan4yin/nix-config/modules/nixos/server/kubevirt-hardware-configuration.nix
#
#  We write our hardware-configuration.nix, so that we can do some customization more easily.
#
#  the url above is used by `nixos-generator` to generate the qcow2 image file.
#
##############################################################################
{
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    boot.growPartition = true;
    boot.kernelParams = ["console=ttyS0"];
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.device = lib.mkDefault "/dev/sda";

    services.qemuGuest.enable = true; # qemu-guest-agent
    services.openssh.enable = true;
    # we configure the host via nixos itself, so we don't need the cloud-init
    services.cloud-init.enable = lib.mkForce false;
    systemd.services."serial-getty@ttyS0".enable = true;

    # TODO: modularize the network configuration
    networking.useDHCP = lib.mkDefault true;
    networking.hostName = lib.mkDefault "nixos";

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}