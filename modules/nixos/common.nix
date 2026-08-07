{
  config,
  inputs,
  pkgs,
  ...
}: {
  programs.niri.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "clash-verge-rev-unwrapped-2.2.3"
    "clash-verge-rev-2.2.3"
    "electron-33.4.11"
  ];

  nix.settings.trusted-users = ["waytrue"];

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.useUserPackages = true;
  home-manager.users.waytrue = {
    imports = [
      ../../home/home.nix
      ../../home/niri.nix
      ../../home/nvf.nix
      inputs.nvf.homeManagerModules.default
      inputs.niri.homeModules.niri
      inputs.dankMaterialShell.homeModules.dank-material-shell
      inputs.dankMaterialShell.homeModules.niri
    ];
  };
}
