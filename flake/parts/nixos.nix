{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  mkPkgsStable = system:
    import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

  mkNixos = {
    system ? "x86_64-linux",
    modules,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        pkgs-stable = mkPkgsStable system;
      };
      modules =
        [
          inputs.home-manager.nixosModules.home-manager
        ]
        ++ modules;
    };

  hostDirs =
    lib.filterAttrs
    (_: type: type == "directory")
    (builtins.readDir "${self}/hosts");

  mkHost = name: _: {
    name = name;
    value = mkNixos {
      modules = ["${self}/hosts/${name}"];
    };
  };
in {
  flake.nixosConfigurations = lib.mapAttrs' mkHost hostDirs;
}
