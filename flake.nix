{
  description = "A NixOS Flake Template";

  nixConfig = {
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    substituers = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nixos-wsl,
    sops-nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = f: lib.genAttrs systems f;
    allHosts = lib.mapAttrs (hostname: _: import ./hosts/${hostname}/system.nix) (builtins.readDir ./hosts);
    nixosHosts = lib.filterAttrs (hostname: hostConfig: hostConfig.type == "nixos" || hostConfig.type == "wsl") allHosts;
    darwinHosts = lib.filterAttrs (hostname: hostConfig: hostConfig.type == "darwin") allHosts;

    in {
    packages = forAllSystems (pkgs: import ./packages {inherit pkgs;});
    formatter = forAllSystems (pkgs: pkgs.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = lib.mapAttrs (hostname: hostConfig: lib.nixosSystem {
        system = hostConfig.arch;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          ./modules/nixos/common/linux.nix
          ./modules/nixos/common/universal.nix
          (lib.mkIf (hostConfig.type == "wsl") nixos-wsl.nixosModules.wsl)
          sops-nix.nixosModules.sops {
            sops.defaultSopsFile = ./secrets/secrets.yaml;
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          }

          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${hostname}" = import ./users/${hostname}/home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      }) nixosHosts;

      darwinConfiguration = lib.mapAttrs (hostname: hostConfig: nix-darwin.lib.darwinSystem {
        system = hostConfig.arch;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          ./modules/nixos/common/universal.nix
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${hostname}" = import ./users/${hostname}/home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      }) darwinHosts;

      apps = forAllSystems (system: {
        new-machine = {
          type = "app";
          program = "${self}/scripts/new-machine.sh";
        };

        new-module = {
          type = "app";
          program = "${self}/scripts/new-module.sh";
        };
      });
  };
}
