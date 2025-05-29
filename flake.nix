{
  description = "NixOS configuration of Ryan Yin";

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
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    stylix.url = "github:danth/stylix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";


  };

  outputs = inputs@{ self, nixpkgs, home-manager,stylix,nixpkgs-stable,nix-darwin,nvf, ... }: {
darwinConfigurations."waytruedeMac-mini" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
     specialArgs = {
	inherit self;
        inherit inputs;
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      };
	modules = [
 ({ config, pkgs, ... }: {
      nixpkgs.config.allowUnfree = true; # 关键：全局允许非自由包
    })
	(./darwin/configuration.nix)
	home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.waytrue = import ./home/home.nix;
          }
];

    };
    



    nixosConfigurations.waytrue-desktop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        # To use packages from nixpkgs-stable,
        # we configure some parameters for it first
        pkgs-stable = import nixpkgs-stable {
          # Refer to the `system` parameter from
          # the outer scope recursively
          inherit system;
          # To use Chrome, we need to allow the
          # installation of non-free software.
          config.allowUnfree = true;
        };

        inherit inputs;
      };
      modules = [ 
      stylix.nixosModules.stylix
      home-manager.nixosModules.home-manager
        ({ config, pkgs, nixpkgs-stable,inputs,... }: {
          # Allow unfree packages and insecure packages
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.permittedInsecurePackages = [ 
            "clash-verge-rev-unwrapped-2.2.3" 
            "clash-verge-rev-2.2.3" 
            "electron-33.4.11"
          ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.waytrue = {
		imports = [
	    ./home/home.nix
            inputs.nvf.homeManagerModules.default
	    ];};
            home-manager.backupFileExtension = "backup";

          # Optional: Explicitly include the package
          environment.systemPackages = [ pkgs.clash-verge-rev ];
        })
        {
         nix.settings.trusted-users = [ "waytrue" ];
        }
       ./os/configuration.nix
      ];
    };
  };
}
