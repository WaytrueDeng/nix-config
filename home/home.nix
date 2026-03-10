{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  tex = pkgs.texlive.combine {
    inherit
      (pkgs.texlive)
      scheme-full
      dvisvgm
      dvipng # for preview and export as html
      wrapfig
      amsmath
      ulem
      hyperref
      capt-of
      ;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  };
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
      feishin
      fzf
      git
      sshfs
      go
      imagemagick
      tex
      wezterm
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
    ]
    ++ (
      if isDarwin
      then [
        darwin.trash
        raycast
        imagej
      ]
      else [
        # 确保以下包名有效：
        bottles
        xunlei-uos
        ocrmypdf
        rofi
        libreoffice
        inkscape
        lutris-unwrapped
        hyprshot
        zotero
        winboat
        gcc
        catppuccin-fcitx5
        wpsoffice-cn
        siyuan
        spotify
        onedrive
        firefox
      ]
    );

  nixpkgs.overlays = [
    (self: super: {
      rPackages = super.rPackages.override {
        overrides = rself: rsuper: {
          tidyplots = rself.buildRPackage {
            name = "tidyplots";
            src = super.fetchFromGitHub {
              owner = "jbengler";
              repo = "tidyplots";
              rev = "COMMIT_HASH"; # 替换为实际commit ID
              sha256 = "HASH_VALUE"; # 通过nix-prefetch-url获取
            };
            propagatedBuildInputs = with rself; [
              ggplot2
              tidyverse
              # 添加其他DESCRIPTION中的依赖
            ];
          };
        };
      };
    })
  ];
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

  #imports = [./nvf.nix];
  imports = [./tmux.nix];
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
  services.mako = lib.mkIf isLinux {
    enable = true;
    defaultTimeout = "5";
  };

  services.blueman-applet = lib.mkIf isLinux {
    enable = true;
  };
}
