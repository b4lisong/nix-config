{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-n" "boot"];
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              label = "nixos";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = ["-L" "nixos"];
                mountpoint = "/";
              };
            };
          };
        };
      };
      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            srv = {
              size = "100%";
              label = "srv";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = ["-L" "srv"];
                mountpoint = "/srv";
              };
            };
          };
        };
      };
    };
  };
}
