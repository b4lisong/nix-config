{
  disko.devices = {
    disk = {
      # Root drive - 20GB SSD with NixOS
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              label = "root";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                  "noatime"
                ];
              };
            };
          };
        };
      };

      # Data drive - 6TB storage with btrfs
      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              label = "nas-data";
              content = {
                type = "btrfs";
                extraArgs = ["-L" "nas-data" "-f"];
                subvolumes = {
                  "/app_config" = {
                    mountpoint = "/mnt/app_config";
                    mountOptions = ["subvol=app_config" "compress=zstd" "noatime"];
                  };
                  "/media" = {
                    mountpoint = "/mnt/media";
                    mountOptions = ["subvol=media" "compress=zstd" "noatime"];
                  };
                  "/pve" = {
                    mountpoint = "/mnt/pve";
                    mountOptions = ["subvol=pve" "compress=zstd" "noatime"];
                  };
                  "/snapshots" = {
                    mountpoint = "/mnt/snapshots";
                    mountOptions = ["subvol=snapshots" "compress=zstd" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}