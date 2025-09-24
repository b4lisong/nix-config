{
  disko.devices = {
    disk = {
      # System SSD - NixOS with legacy boot
      sde = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WDS500G1R0A-68A4W0_2041DA803271";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02"; # BIOS boot partition
            };
            boot = {
              size = "512M";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                mountOptions = ["defaults" "noatime"];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };

      # Storage array - 4 spinning disks for RAIDZ10
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW6034KJ";
        content = {
          type = "zfs";
          pool = "storage";
        };
      };
      sdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Hitachi_HDS5C4040ALE630_PL1321LAG349UH";
        content = {
          type = "zfs";
          pool = "storage";
        };
      };
      sdc = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW60VLBG";
        content = {
          type = "zfs";
          pool = "storage";
        };
      };
      sdd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW61YBDS";
        content = {
          type = "zfs";
          pool = "storage";
        };
      };
    };

    zpool = {
      # System pool on SSD
      rpool = {
        type = "zpool";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        options = {
          compatibility = "grub2";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options.mountpoint = "legacy";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
          incus = {
            type = "zfs_fs";
            mountpoint = "/incus";
            options.mountpoint = "legacy";
          };
        };
      };

      # Storage pool - RAIDZ10 (mirror of two RAIDZ1 vdevs)
      storage = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz1";
                members = ["sda" "sdb"];
              }
              {
                mode = "raidz1";
                members = ["sdc" "sdd"];
              }
            ];
          };
        };
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          app_config = {
            type = "zfs_fs";
            mountpoint = "/mnt/app_config";
            options.mountpoint = "legacy";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/mnt/media";
            options.mountpoint = "legacy";
          };
          backup = {
            type = "zfs_fs";
            mountpoint = "/mnt/backup";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}