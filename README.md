# NixOS & Darwin Configuration Template

This repository contains my personal take for managing NixOS, macOS (via `nix-darwin`), and WSL systems using a single, scalable Nix Flake. It's designed to be modular, reproducible, and easy to expand.

## Core Philosophy

This configuration is built on a few key principles:

* **Hosts vs. Users**: System-level configurations (**hosts**) are kept separate from user-level dotfiles and packages (**users**).
* **Modularity**: Reusable sets of configurations (**modules**) encapsulate features like security hardening, specific applications, or services.
* **Automation**: Scripts automate the creation of new machines, users, and modules, ensuring consistency and reducing boilerplate.

---

## Directory Structure

├── flake.nix # Main flake entry point 
├── hosts/ # Machine-specific configurations 
│  └── USER_NAME/
│     ├── default.nix # NixOS/Darwin system modules
│     ├── hardware-confugration.nix # Hardware-specifics (for NixOS) 
│     └── system.nix # Machine metadata (type and arch) 
├── users/ # User-specific Home Manager configs 
│  └── USER_NAME/ 
│     └── home.nix # Home Manager modules for this user 
├── modules/ # Reusable configuration modules 
│  ├── nixos/ # System-level modules (e.g., security.nix)
│  └── home-manager/ # Home Manager modules (e.g., apps/neovim.nix) 
├── secrets/ # Encrypted secrets managed by sops 
└── templates/ # Boilerplate files for scaffolding scripts

---

## Usage

This flake includes several helper scripts to automate common tasks.

### Prerequisites

Ensure you have Nix installed with flakes enabled.

### Onboarding a New Machine

To add a new computer to your configuration (whether it's NixOS, macOS, or WSL):

1.  Run the `new-machine` script from the flake's root directory. The script will guide you through selecting the system type and architecture.

    ```bash
    # Usage: nix run .#new-machine -- <hostname>
    nix run .#new-machine -- my-laptop
    ```

2.  For NixOS systems, generate the hardware configuration on the new machine and save it to the newly created `hosts/<hostname>/hardware.nix` file.

    ```bash
    # On the target machine, after booting into a NixOS installer:
    sudo nixos-generate-config --no-filesystems --root /mnt --dir /path/to/your/flake/hosts/my-laptop
    ```

3.  Customize the new host and user files located at `hosts/my-laptop/default.nix` and `users/my-laptop/home.nix` by importing the modules you need.

### Adding New Modules

To create a new, reusable module for a system feature or an application:

* **For system-level modules (NixOS):**

    ```bash
    # Usage: nix run .#new-module -- nixos <module-name>
    nix run .#new-module -- nixos zfs
    ```

* **For user-level modules (Home Manager):**

    ```bash
    # Usage: nix run .#new-module -- home-manager <module-name>
    nix run .#new-module -- home-manager shell
    ```

> [!WARNING]
> - THIS IS VERY EXPERIMENTAL AND IS NOT RECOMMENDED FOR PRODUCTION USE
> - YOU ARE RESPONSIBLE FOR ANY DAMAGES TO YOUR SYSTEM

## Credits
Misterio77 nix-starter-config was a big insipiration for this template
