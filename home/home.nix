{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in

{
  home.username = "waytrue";
  home.homeDirectory = lib.mkForce (if isDarwin then "/Users/waytrue" else "/home/waytrue"); 


  home.packages = with pkgs; [
    fzf git unzip zellij neovim dig tldr zoxide 
  ] ++ (if isDarwin then [
    darwin.trash raycast wezterm
  ] else [
    # 确保以下包名有效：
    inkscape
    lutris-unwrapped
    hyprshot
    rustdesk
    onedrivegui
    firefox
    gcc
    catppuccin-fcitx5
    wpsoffice-cn
    spotify
    onedrive
  ]);

  programs.home-manager.enable = true;
  
  programs.aerospace = lib.mkIf isDarwin {
    enable = true;
  };
  programs.nushell = {
    enable = true;
    shellAliases = {
      ns = "doas nixos-rebuild switch --flake ${config.home.homeDirectory}/Documents/nix-config#waytrue-desktop";
      hmf = "nvim ${config.home.homeDirectory}/Documents/nix-config/home/home.nix";
    };
  };

  programs.fish = {
    enable = true;
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };

  home.file = {
    ".config/waybar".source = ./config/waybar;
    ".config/rofi".source = ./config/rofi;
    ".config/nvim".source = ./config/nvim;
  };

  #imports = [ ./nvf.nix ];
  home.stateVersion = "25.05";
  home.sessionVariables.XMODIFIERS = "@im=fcitx";

  # Linux 专属配置
  xdg.mimeApps = lib.mkIf isLinux {
    enable = true;
    defaultApplications = {
      "application/xhtml+xml" = "microsoft-edge.desktop";
      "text/html" = "microsoft-edge.desktop";
      "text/xml" = "microsoft-edge.desktop";
      "x-scheme-handler/ftp" = "microsoft-edge.desktop";
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
    };
  };

  wayland.windowManager.hyprland = lib.mkIf isLinux {
    enable = true;
    systemd.enable = true;
    systemd.enableXdgAutostart = true;
    extraConfig = lib.fileContents ./config/hyprland.conf;
  };

  programs.waybar = lib.mkIf isLinux { enable = true; };
  programs.wlogout = lib.mkIf isLinux { enable = true; };
  programs.rofi = lib.mkIf isLinux { enable = true; package = pkgs.rofi-wayland; };

  fonts.fontconfig = lib.mkIf isLinux {
    enable = true;
    defaultFonts = {
      monospace = [ "LXGW WenKai Mono" "Noto Sans Mono CJK SC" "Sarasa Mono SC" "DejaVu Sans Mono" ];
      sansSerif = [ "LXGW WenKai" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  services.mako = lib.mkIf isLinux {
    enable = true;
    defaultTimeout = "5";
  };

  services.blueman-applet = lib.mkIf isLinux {
    enable = true;
  };
}
