{
  description = "Home Manager configuration of maxou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
    stylix.url = "github:danth/stylix";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixgl,
      stylix,
      nix-flatpak,
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
                nixgl.overlay
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
            ];
          };
        }
      );

      packages = forEachSupportedSystem (
        { pkgs }:
        let
          mkHome = username: stateVersion: mkHomeExtra username stateVersion [ ];
          mkHomeExtra =
            username: stateVersion: extraModules:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                {
                  home.username = username;
                  home.homeDirectory = nixpkgs.lib.mkDefault (
                    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
                  );
                  home.stateVersion = stateVersion;
                }
                nix-flatpak.homeManagerModules.nix-flatpak
                stylix.homeModules.stylix
                ./home
              ] ++ extraModules;
            };
        in
        {
          homeConfigurations = {
            "maxou@gertry" = mkHome "maxou" "24.11";
            "maxou@glados" = mkHomeExtra "maxou" "24.11" [
              {
                home.graphical.enable = true;
              }
            ];
            "maxou@wheatley" = mkHome "maxou" "20.09";
            "maxverzier@mverzier-laptop-00495" = mkHome "maxverzier" "25.05";
          };
        }
      );
    };
}
