{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/common.nix
    ../../os/hardware-configuration-desktop.nix
  ];

  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
    };
  };

  services.displayManager.ly.enable = true;
  users.groups.waytrue = {};
  users.users.waytrue = {
    group = "waytrue";
    extraGroups = ["libvirtd"];
  };

  environment.etc."gitconfig".text = ''
    [safe]
      directory = /home/waytrue/Documents/nix-config
  '';

  environment.systemPackages = [
    pkgs.clash-verge-rev
    pkgs.looking-glass-client
    inputs.logseq-nightly.packages.${pkgs.system}.logseq
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
  };
  programs.virt-manager.enable = true;
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 waytrue libvirtd -"
  ];

  services.synergy.server = {
    enable = true;
    address = "0.0.0.0:24800";
  };
}
