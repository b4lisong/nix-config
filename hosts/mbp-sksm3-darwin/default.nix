_:
#############################################################
#
#  sksm3 - MacBook Pro 2023 14-inch M3 Pro 18G, mainly for work use
#
#############################################################
let
  hostname = "sksm3";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}
