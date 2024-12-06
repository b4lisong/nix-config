# Add host-specific applications here
{pkgs, ...}: {
  homebrew = {
    brews = [
    ];
    casks = [
      # Communication tools
      "superhuman"
      "slack"

      # Media
      "spotify"

      # Pentest tools
      "burp-suite-professional"
      "bloodhound" # xattr -d com.apple.quarantine ./BloodHound.
      "neo4j" # for bloodhound
    ];
    masApps = {
    };
  };
}
