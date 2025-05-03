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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";

  };

  outputs = inputs@{ self, nixpkgs, home-manager,catppuccin,nixpkgs-stable, ... }: {
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
      };
      modules = [ 
      home-manager.nixosModules.home-manager

        ({ config, pkgs, nixpkgs-stable,... }: {
          # Allow unfree packages and insecure packages
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.permittedInsecurePackages = [ 
            "clash-verge-rev-unwrapped-2.2.3" 
            "clash-verge-rev-2.2.3" 
            "clash-verge-rev-webui-2.2.3" 
            "clash-verge-rev-service-2.2.3" 
          ];


          # Optional: Explicitly include the package
          environment.systemPackages = [ pkgs.clash-verge-rev ];
        })
	          {
            # given the users in this list the right to specify additional substituters via:
            #    1. `nixConfig.substituters` in `flake.nix`
            nix.settings.trusted-users = [ "waytrue" ];
          }
        ./os/configuration.nix
	 home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.waytrue = {
		imports = [
	    ./home/home.nix
            catppuccin.homeManagerModules.catppuccin {
		catppuccin.enable = true;
		catppuccin.flavor = "latte";

	    }


	    ];};
            home-manager.backupFileExtension = "backup";



            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
      ];
    };
  };
}
