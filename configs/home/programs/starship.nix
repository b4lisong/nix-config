# configs/home/programs/starship.nix
# Master starship configuration - custom Kali Linux inspired prompt
# NerdFont symbols definitions: https://starship.rs/presets/nerd-font
{
  add_newline = true;

  format = ''
    [┌╴\(](bold green)[$username$os$hostname](bold blue)[\)](bold green)$container $time
    [|](bold green) $all[└─](bold green) $character
  '';

  character = {
    success_symbol = "[❯](bold green)";
    error_symbol = "[✗](bold red)";
    vicmd_symbol = "[CMD❮](bold yellow)";
  };

  username = {
    style_user = "blue bold";
    style_root = "red bold";
    format = "[$user]($style)";
    disabled = false;
    show_always = true;
  };

  hostname = {
    ssh_only = false;
    format = "[$ssh_symbol](bold blue)[$hostname](bold blue)";
    trim_at = ".companyname.com";
    disabled = false;
    ssh_symbol = " ";
  };

  # OS symbol configuration
  os = {
    style = "bold white";
    format = "@[$symbol$arch](style)";
    disabled = false;
  };

  os.symbols = {
    Alpaquita = " ";
    Alpine = " ";
    AlmaLinux = " ";
    Amazon = " ";
    Android = " ";
    Arch = " ";
    Artix = " ";
    CachyOS = " ";
    CentOS = " ";
    Debian = " ";
    DragonFly = " ";
    Emscripten = " ";
    EndeavourOS = " ";
    Fedora = " ";
    FreeBSD = " ";
    Garuda = "󰛓 ";
    Gentoo = " ";
    HardenedBSD = "󰞌 ";
    Illumos = "󰈸 ";
    Kali = " ";
    Linux = " ";
    Mabox = " ";
    Macos = " ";
    Manjaro = " ";
    Mariner = " ";
    MidnightBSD = " ";
    Mint = " ";
    NetBSD = " ";
    NixOS = " ";
    Nobara = " ";
    OpenBSD = "󰈺 ";
    openSUSE = " ";
    OracleLinux = "󰌷 ";
    Pop = " ";
    Raspbian = " ";
    Redhat = " ";
    RedHatEnterprise = " ";
    RockyLinux = " ";
    Redox = "󰀘 ";
    Solus = "󰠳 ";
    SUSE = " ";
    Ubuntu = " ";
    Unknown = " ";
    Void = " ";
    Windows = "󰍲 ";
  };

  # Git configuration
  git_branch = {
    truncation_length = 16;
    truncation_symbol = "...";
    disabled = false;
    symbol = " ";
  };

  git_status = {
    disabled = false;
  };

  git_commit = {
    commit_hash_length = 4;
    tag_disabled = false;
    only_detached = false;
    tag_symbol = "  ";
  };

  # Directory configuration
  directory = {
    truncation_length = 8;
    truncation_symbol = "…/";
    truncate_to_repo = true;
    read_only = "🔒";
  };

  # Time configuration
  time = {
    disabled = false;
    format = "[$time]($style) ";
    style = "bold yellow";
  };

  # Additional modules that enhance the prompt
  container = {
    disabled = false;
    format = "[$symbol$name]($style) ";
  };

  # Nix shell indicator (useful for your Nix workflow)
  nix_shell = {
    disabled = false;
    format = "via[$symbol$state( \($name\))]($style) ";
    symbol = "️ ";
  };

  # Development environment indicators
  nodejs = {
    disabled = false;
    format = "via [$symbol($version )]($style)";
    symbol = " ";
  };

  python = {
    disabled = false;
    format = "via [$symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
    symbol = " ";
  };

  rust = {
    disabled = false;
    format = "via [$symbol($version )]($style)";
    symbol = " ";
  };

  golang = {
    disabled = false;
    format = "via [$symbol($version )]($style)";
    symbol = " ";
  };

  # Package version indicators
  package = {
    disabled = false;
    format = "is [$symbol$version]($style) ";
    symbol = "󰏗 ";
  };

  # Docker context (disabled by default, enable per-host if needed)
  docker_context = {
    disabled = true;
    format = "via [$symbol$context]($style) ";
    symbol = " ";
  };

  # Kubernetes context (disabled by default, enable per-host if needed)
  kubernetes = {
    disabled = true;
    format = "on [$symbol$context( \($namespace\))]($style) ";
  };
}