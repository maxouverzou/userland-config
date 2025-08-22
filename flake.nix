{
  description = "Home Manager configuration of maxou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
    stylix.url = "github:nix-community/stylix";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:

    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                inputs.nixgl.overlay
                (import ./overlays)
              ];
              config.allowUnfree = true;
              config.allowUnsupportedSystem = false;
              config.allowBroken = false;
            };
          }
        );
    in
    {
      formatter = forEachSupportedSystem ({ pkgs }: pkgs.nixfmt-tree);

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = [
              home-manager.packages.${pkgs.system}.default
              pkgs.ssh-to-age
              pkgs.sops
            ];
          };
        }
      );

      packages = forEachSupportedSystem (
        { pkgs }:
        let
          mkHome =
            cfg:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                inputs.nix-flatpak.homeManagerModules.nix-flatpak
                inputs.stylix.homeModules.stylix
                inputs.sops-nix.homeManagerModules.sops
                ./modules
                {
                  config = {
                    nix.gc = {
                      automatic = true;
                      persistent = true;
                    };
                    sops = {
                      age.keyFile = nixpkgs.lib.mkDefault "/etc/ssh/ssh_host_ed25519_key.pub";
                      defaultSopsFile = ./secrets/main.yaml;
                    };
                  };
                }
                cfg
              ];
            };
        in
        {
          homeConfigurations = {
            "maxou@gertry" = mkHome {
              home = {
                username = "maxou";
                homeDirectory = "/home/maxou";
                stateVersion = "24.11";
              };
            };
            "maxou@glados" = mkHome {
              home = {
                username = "maxou";
                homeDirectory = "/home/maxou";
                stateVersion = "24.11";
              };
              sops.age.keyFile = "/home/maxou/.config/sops/age/keys.txt";
              enableDevelopment = true;
              enableGraphical = true;
            };
            "maxou@wheatley" = mkHome {
              home = {
                username = "maxou";
                homeDirectory = "/home/maxou";
                stateVersion = "20.09";
              };
            };
            "maxverzier@mverzier-laptop-00495" = mkHome {
              home = {
                username = "maxverzier";
                homeDirectory = "/Users/maxverzier";
                stateVersion = "25.05";
              };
              enableDevelopment = true;
            };
          };
        }
      );
    };
}
