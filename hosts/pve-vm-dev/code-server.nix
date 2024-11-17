{
  config,
  myvars,
  ...
}: {
  services.code-server = {
    enable = true;
    user = "${myvars.username}";
    auth = "none";
    host = "0.0.0.0";
    extraGroups = ["docker"];
    disableWorkspaceTrust = true;
    disableTelemetry = true;
    disableGettingStartedOverride = true;
  };
}
