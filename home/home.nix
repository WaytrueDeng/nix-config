{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in {
  home.username = "waytrue";
  home.homeDirectory = lib.mkForce (
    if isDarwin
    then "/Users/waytrue"
    else "/home/waytrue"
  );

  home.packages = with pkgs;
    [
      poppler_data
      poppler
      nix-search-tv
      nerd-fonts.fira-code
      corefonts
      wqy_microhei
      android-tools
      uv
      btop
      cargo
      dig
      eza
      fastfetch
      fzf
      git
      sshfs
      go
      imagemagick
      neovim
      spotify
      tldr
      typst
      unzip
      wget
      aria2
      yazi
      tmux
      zoxide
      pdfarranger
      ripgrep
      xwayland-satellite
      xsettingsd
    ]
    ++ (
      if isDarwin
      then [
        darwin.trash
        raycast
        imagej
      ]
      else [
        (pkgs.rstudioWrapper.override {
          packages = with pkgs.rPackages; [
            ggplot2
            dplyr
            xts
          ];
        })
        wemeet
        wechat-uos
        bottles
        xunlei-uos
        ocrmypdf
        rofi
        libreoffice
        lutris-unwrapped
        localsend
        zotero
        winboat
        gcc
        catppuccin-fcitx5
        adw-gtk3
        wpsoffice-cn
        siyuan
        spotify
        onedrive
        firefox
        qt6Packages.qt6ct
      ]
    );

  programs.home-manager.enable = true;

  programs.aerospace = lib.mkIf isDarwin {
    enable = true;
    userSettings = lib.trivial.importTOML ./config/aerospace/aerospace.toml;
  };
  programs.nushell = {
    enable = true;
    shellAliases = {
      ns = "doas nixos-rebuild switch --flake ${config.home.homeDirectory}/Documents/nix-config#waytrue-desktop";
      hmf = "nvim ${config.home.homeDirectory}/Documents/nix-config/home/home.nix";
    };
    extraConfig = ''
      def snp [] {
        nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history
      }
    '';
  };

  programs.fish = {
    enable = true;
    functions = {
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };
    shellInit = ''
      set -gx EDITOR nvim  # 全局生效
    '';
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
    #".config/nvim".source = ./config/nvim;
    ".config/kanshi".source = ./config/kanshi;
  };

  imports = [./nvf.nix ./tmux.nix];
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
  programs.kitty = {
    enable = true;
    extraConfig = ''
            include dank-tabs.conf
            include dank-theme.conf
            # 1. 设置字体为 JetBrains Mono
      font_family JetBrainsMono

      # 2. 设置背景透明度 (0.0为完全透明，1.0为完全不透明)
      background_opacity 1.0

      # 3. （关键步骤）启用动态透明度调整，使透明度设置生效
      dynamic_background_opacity yes
    '';
  };
  programs.waybar = lib.mkIf isLinux {enable = true;};
  programs.wlogout = lib.mkIf isLinux {enable = true;};
  programs.rofi = lib.mkIf isLinux {
    enable = true;
    package = pkgs.rofi;
  };

  fonts.fontconfig = lib.mkIf isLinux {
    enable = true;
    defaultFonts = {
      monospace = ["LXGW WenKai Mono" "Noto Sans Mono CJK SC" "Sarasa Mono SC" "DejaVu Sans Mono"];
      sansSerif = ["LXGW WenKai"];
      serif = ["DejaVu Serif"];
    };
  };

  services.xsettingsd = lib.mkIf isLinux {
    enable = true;

    settings = {
      "Xft/DPI" = 368640; # 可选，匹配360 DPI
      "Xft/Antialias" = true;
      "Xft/Hinting" = 1;
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
