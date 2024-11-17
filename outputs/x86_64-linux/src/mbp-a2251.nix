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
  name = "a2251";
  tags = ["bm" "client"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        # TODO: add secrets
        # "secrets/nixos.nix"
        "modules/nixos/desktop"
        # host specific
        "hosts/mbp-${name}"
      ])
      ++ [
        # TODO: configure modules.secrets.server
        #{modules.secrets.server.application.enable = true;}
        #{modules.secrets.server.operation.enable = true;}
        #{modules.secrets.server.webserver.enable = true;}
        #{modules.secrets.server.storage.enable = true;}
      ];
    home-modules = map mylib.relativeToRoot [
      "home/linux/gui.nix"
      # host specific
      "hosts/mbp-${name}/home.nix"
    ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  # TODO: colmena
  #colmena.${name} =
  #  mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  # generate iso image for hosts with DE
  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
}
