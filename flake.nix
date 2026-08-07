{
  description = "nixos config of waytrue deng";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # override the default substituters
    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      #"https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"

      # nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      # nix community's cache server public key
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-logseq-git-flake.cachix.org-1:DSBNW07PSRyCvS926tpIWahb53OIydwwZhsP6LhJNZo="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    affinity-nix.url = "github:mrshmllow/affinity-nix";
    logseq-nightly.url = "github:Bad3r/nix-logseq-git-flake";
    ## optional: share nixpkgs
    logseq-nightly.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nsticky = {
      url = "github:lonerOrz/nsticky";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    nixpkgs-stable,
    niri,
    dankMaterialShell,
    affinity-nix,
    nsticky,
    logseq-nightly,
    ...
  }: let
    mkPkgsStable = system:
      import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

    mkNixos = {
      system ? "x86_64-linux",
      modules,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          pkgs-stable = mkPkgsStable system;
        };
        modules =
          [
            home-manager.nixosModules.home-manager
          ]
          ++ modules;
      };
  in {
    nixosConfigurations.waytrue-laptop = mkNixos {
      modules = [./hosts/waytrue-laptop];
    };

    nixosConfigurations.waytrue-desktop = mkNixos {
      modules = [./hosts/waytrue-desktop];
    };
  };
}
