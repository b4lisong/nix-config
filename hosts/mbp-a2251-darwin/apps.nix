# Add host-specific applications here
{pkgs, ...}: {
  homebrew = {
    masApps = {
      # utility for keeping system awake (e.g. when lid is closed)
      # note: also need to install Amphetamine Enhancer; currently done manually, but
      # TODO: automate per https://github.com/x74353/Amphetamine-Enhancer/issues/5#issuecomment-963530521
      "Amphetamine" = 937984704;
    };
  };
}
