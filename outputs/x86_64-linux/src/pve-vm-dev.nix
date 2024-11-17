# inspired by
# ryan4yin/nix-config/outputs/x86_64-linux/src/idols-aquamarine.nix
# ryan4yin/nix-config/outputs/x86_64-linux/src/12kingdoms-shoukei.nix
{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
} @ args: let
  # remote development VM (in Proxmox VE)
  name = "dev";
  tags = ["vm" "bh" "pve" "railyard"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        # TODO: add secrets
        # "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        "modules/nixos/server/pve-vm-hardware-configuration.nix"
        "modules/nixos/server/kmscon.nix"
        # host specific
        "hosts/pve-vm-${name}"
      ])
      ++ [
        # TODO: configure modules.secrets.server
        #{modules.secrets.server.application.enable = true;}
        #{modules.secrets.server.operation.enable = true;}
        #{modules.secrets.server.webserver.enable = true;}
        #{modules.secrets.server.storage.enable = true;}
      ];
    home-modules = map mylib.relativeToRoot [
      "home/linux/tui.nix"
    ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  # TODO: colmena
  #colmena.${name} =
  #  mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  #packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.kubevirt;
  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.qcow; # for Proxmox VE
}
