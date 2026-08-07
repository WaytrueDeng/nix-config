{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ../../os/configuration.nix
  ];

  environment.systemPackages = [
    pkgs.clash-verge-rev
    inputs.affinity-nix.packages.${pkgs.system}.v3
  ];
}
