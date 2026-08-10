{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ../../modules/nixos/common.nix
    ]
    ++ lib.optionals (builtins.pathExists ../../os/hardware-configuration.nix) [
      ../../os/hardware-configuration.nix
    ];

  services.displayManager.gdm.enable = true;

  environment.systemPackages = [
    pkgs.clash-verge-rev
    pkgs.wechat-uos
    inputs.affinity-nix.packages.${pkgs.system}.v3
  ];
}
