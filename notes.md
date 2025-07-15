# Machine Setup Instructions

## For New Machines Using Existing Configuration

1. **Install Nix**
   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```
   - Choose 'no' when prompted to install the Determinate distribution to install the recommended vanilla upstream Nix.

2. **Clone Configuration Repository**
   ```bash
   git clone https://github.com/b4lisong/nix-config.git
   cd nix-config
   ```

3. **Check Available Machine Configurations**
   ```bash
   # View defined machines in variables/default.nix
   grep -A 5 "hosts = {" variables/default.nix
   ```

4. **Use Existing Machine Configuration**
   ```bash
   # For existing machines (a2251, sksm3, rpi4b):
   sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#<hostname>
   sudo darwin-rebuild switch --flake .#<hostname>
   
   # Examples:
   # sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#a2251
   # sudo darwin-rebuild switch --flake .#sksm3
   ```

## For Adding New Machines to Configuration

1. **Follow steps 1-2 above to install Nix and clone repository**

2. **Create new branch for machine setup**
   ```bash
   git checkout -b <new-hostname>
   git push -u origin <new-hostname>
   ```

3. **Add machine definition to variables/default.nix**
   ```nix
   <hostname> = {
     hostname = "<hostname>";
     system = "<architecture>"; # "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel
     description = "<description>";
   };
   ```

4. **Create host configuration files**
   ```bash
   mkdir hosts/<hostname>
   # Create hosts/<hostname>/system.nix (based on existing examples)
   # Create hosts/<hostname>/home.nix (based on existing examples)
   ```

5. **Add to flake.nix darwinConfigurations**
   ```nix
   darwinConfigurations.${vars.hosts.<hostname>.hostname} =
     nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.<hostname>.hostname);
   ```

6. **Test and apply configuration**
   ```bash
   git add .
   git commit -m "feat: add <hostname> machine configuration"
   nix flake check  # Verify configuration syntax
   sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#<hostname>
   sudo darwin-rebuild switch --flake .#<hostname>
   ```

## Architecture Notes

- **Apple Silicon Macs**: Use `"aarch64-darwin"`
- **Intel Macs**: Use `"x86_64-darwin"`
- **Linux ARM**: Use `"aarch64-linux"` (future support)

## Current Defined Machines

- **a2251**: Personal MacBook Pro (Intel) - `x86_64-darwin`
- **sksm3**: Work MacBook (Apple Silicon) - `aarch64-darwin`  
- **rpi4b**: Raspberry Pi 4B (ARM Linux) - `aarch64-linux`