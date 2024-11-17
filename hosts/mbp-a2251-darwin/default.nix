_:
#############################################################
#
#  a2251 - MacBook Pro 2020 13-inch i5 16G, mainly for personal use
#
#############################################################
let
  hostname = "a2251";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}