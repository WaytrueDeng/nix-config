{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ../../os/configuration-desktop.nix
  ];

  environment.systemPackages = [
    pkgs.clash-verge-rev
    inputs.logseq-nightly.packages.${pkgs.system}.logseq
  ];
}
