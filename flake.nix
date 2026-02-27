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

    nix-ai-bubbles = {
      url = "github:maxouverzou/nix-ai-bubbles";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-distribution.url = "github:maxouverzou/pi-distribution";
    pi-distribution.inputs.nixpkgs.follows = "nixpkgs";

    bun2nix.url = "github:nix-community/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
    
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
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            inputs.bun2nix.overlays.default
            inputs.nix-ai-bubbles.overlays.default
            inputs.pi-distribution.overlays.default
            inputs.nixgl.overlay
            (import ./overlays)
          ];
          config.allowUnfree = true;
          config.allowUnsupportedSystem = false;
          config.allowBroken = false;
        };
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f { pkgs = mkPkgs system; }
        );
      mkHome =
        system: cfg:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.stylix.homeModules.stylix
            inputs.sops-nix.homeManagerModules.sops
            inputs.pi-distribution.homeManagerModules.default
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
                  secrets = {
                    RCLONE_GDRIVE_CLIENT = { };
                    RCLONE_GDRIVE_SECRET = { };
                  };
                };
              };
            }
            cfg
          ];
        };
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

              pkgs.nix-prefetch-git
              pkgs.nix-prefetch-github

              pkgs.bun
              inputs.bun2nix.packages.${pkgs.system}.default
            ];
          };
        }
      );

      packages = forEachSupportedSystem (
        { pkgs }:
        import ./packages { inherit pkgs; }
      );

      homeConfigurations = {
        "maxou@gertry" = mkHome "x86_64-linux" {
          home = {
            username = "maxou";
            homeDirectory = "/home/maxou";
            stateVersion = "24.11";
          };
        };
        "maxou@glados" = mkHome "x86_64-linux" {
          home = {
            username = "maxou";
            homeDirectory = "/home/maxou";
            stateVersion = "24.11";
          };
          sops.age.keyFile = "/home/maxou/.config/sops/age/keys.txt";
          enableDevelopment = true;
          enableGraphical = true;
          enablePersonal = true;
        };
        "maxou@wheatley" = mkHome "x86_64-linux" {
          home = {
            username = "maxou";
            homeDirectory = "/home/maxou";
            stateVersion = "20.09";
          };
        };
        "maxverzier@mverzier-laptop-00495" = mkHome "aarch64-darwin" {
          home = {
            username = "maxverzier";
            homeDirectory = "/Users/maxverzier";
            stateVersion = "25.05";
          };
          enableDevelopment = true;
        };
      };
    };
}
