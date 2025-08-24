-- WakaTime time tracking plugin
-- Tracks coding time and provides metrics for productivity insights
return {
  'wakatime/vim-wakatime',
  lazy = false,
  config = function()
    -- Plugin automatically downloads and updates wakatime-cli
    -- Configuration is managed via ~/.wakatime.cfg
    -- Use :WakaTimeApiKey to set up your API key after installation
    -- Use :WakaTimeDebugEnable for troubleshooting
  end,
}