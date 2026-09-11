{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  qqmusicScaled = pkgs.symlinkJoin {
    name = "qqmusic-scaled";
    paths = [pkgs.qqmusic];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/qqmusic \
        --unset NIXOS_OZONE_WL \
        --set ELECTRON_OZONE_PLATFORM_HINT x11 \
        --set GDK_SCALE 1 \
        --set GDK_DPI_SCALE 1 \
        --add-flags "--high-dpi-support=1" \
        --add-flags "--ozone-platform=x11" \
        --add-flags "--force-device-scale-factor=0.8"
    '';
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
      codex
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
        qt6Packages.qt6ct
        qqmusicScaled
      ]
    );

  programs.home-manager.enable = true;
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi # 添加这个
    ];
  };
  programs.aerospace = lib.mkIf isDarwin {
    enable = true;
    userSettings = lib.trivial.importTOML ./config/aerospace/aerospace.toml;
  };
  programs.nushell = {
    enable = false;
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
    enable = false;
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
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ns = "doas nixos-rebuild switch --flake ${config.home.homeDirectory}/Documents/nix-config#waytrue-desktop";
      hmf = "nvim ${config.home.homeDirectory}/Documents/nix-config/home/home.nix";
    };
    initContent = ''
      export EDITOR=nvim

      if [[ -o interactive ]] && command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]]; then
        exec tmux new-session -A -s default
      fi

      snp() {
        nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history
      }

      bindkey -M viins '^R' fzf-history-widget
    '';
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  home.file = {
    #".config/waybar".source = ./config/waybar;
    ".config/rofi".source = ./config/rofi;
    #".config/nvim".source = ./config/nvim;
    #".config/kanshi".source = ./config/kanshi;
  };

  imports = [
    ../modules/home/niri.nix
    ../modules/home/nvf.nix
    ../modules/home/tmux.nix
  ];
  waytrue.niri.enable = true;
  waytrue.nvf.enable = true;
  waytrue.tmux.enable = true;

  home.stateVersion = "25.05";
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    XMODIFIERS = "@im=fcitx";
  };

  xdg.configFile = lib.mkIf isLinux {
    "fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=rime

      [Groups/0/Items/0]
      Name=rime
      Layout=

      [GroupOrder]
      0=Default
    '';
  };

  home.activation.fcitxRimeConfig = lib.mkIf isLinux (
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      rime_dir="${config.xdg.dataHome}/fcitx5/rime"
      run mkdir -p "$rime_dir"
      run rm -f "$rime_dir/default.custom.yaml"
      run rm -f "$rime_dir/double_pinyin_flypy.custom.yaml"
      run ${pkgs.coreutils}/bin/install -m 0644 ${
        pkgs.writeText "default.custom.yaml" "patch:\n  schema_list:\n    - schema: double_pinyin_flypy\n"
    } "$rime_dir/default.custom.yaml"
      run ${pkgs.coreutils}/bin/install -m 0644 ${
        pkgs.writeText "double_pinyin_flypy.custom.yaml" ''
          patch:
            switches/@2/reset: 1
            punctuator/import_preset: symbols
            recognizer/patterns/punct: "^/([0-9]0?|[A-Za-z]*)$"
        ''
    } "$rime_dir/double_pinyin_flypy.custom.yaml"
  ''
);

  # Linux 专属配置
  xdg.mimeApps = lib.mkIf isLinux {
    enable = true;
    defaultApplications = {
      "application/xhtml+xml" = "zen.desktop";
      "text/html" = "zen.desktop";
      "text/xml" = "zen.desktop";
      "x-scheme-handler/ftp" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
    };
  };

  wayland.windowManager.hyprland = lib.mkIf isLinux {
    enable = false;
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
  programs.waybar = lib.mkIf isLinux {enable = false;};
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
    enable = false;
    defaultTimeout = "5";
  };

  services.blueman-applet = lib.mkIf isLinux {
    enable = true;
  };
}
