{
  config,
  pkgs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "waytrue";
  home.homeDirectory = "/home/waytrue";
  home.packages = with pkgs; [
    catppuccin-fcitx5
    fzf
    wpsoffice-cn
    inkscape
    fiji
    git
    spotify
    unzip
    zellij
    onedrive
    onedrivegui
    lutris-unwrapped
    hyprshot
    rustdesk
    neovim
    affine
    dig
    tldr
    feishin
  ];
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # "application/xhtml+xml" = "${lib.getExe pkgs.microsoft-edge}/share/applications/firefox.desktop";
      # "text/html" = "${lib.getExe pkgs.microsoft-edge}/share/applications/firefox.desktop";
      # "text/xml" = "${lib.getExe pkgs.microsoft-edge}/share/applications/firefox.desktop";
      # "x-scheme-handler/ftp" = "${lib.getExe pkgs.microsoft-edge}/share/applications/firefox.desktop";
      # "x-scheme-handler/http" = "${lib.getExe pkgs.microsoft-edge}/share/applications/firefox.desktop";
      # "x-scheme-handler/https" = "${lib.getExe pkgs.microsoft-edge}/share/applications/firefox.desktop";
      "application/xhtml+xml" = "microsoft-edge.desktop";
      "text/html" = "microsoft-edge.desktop";
      "text/xml" = "microsoft-edge.desktop";
      "x-scheme-handler/ftp" = "microsoft-edge.desktop";
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.enableXdgAutostart = true;
    extraConfig = lib.fileContents ./config/hyprland.conf;
  };

  i18n.inputMethod.fcitx5.settings.addons = {
    classicui.sections.Theme = "catppuccin-latte-lavender";
    classicui.sections.DarkTheme = "catppuccin-latte-lavender";
  };

  programs.waybar = {
    enable = true;
  };

  programs.wlogout = {
    enable = true;
  };
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };
  programs.nushell = {
    enable = true;
    shellAliases = {
      ns = "doas nixos-rebuild switch --flake /home/waytrue/Documents/nix-config#waytrue-desktop";
      hmf = "nvim /home/waytrue/Documents/nix-config/home/home.nix";
    };
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "LXGW WenKai Mono"
        "Noto Sans Mono CJK SC"
        "Sarasa Mono SC"
        "DejaVu Sans Mono"
      ];
      sansSerif = [
        "LXGW WenKai"
      ];
      serif = [
        "DejaVu Serif"
      ];
    };
  };

  home.file = {
    ".config/waybar" = {
      enable = true;
      source = ./config/waybar;
      recursive = true;
    };
    ".config/rofi" = {
      enable = true;
      source = ./config/rofi;
      recursive = true;
    };
    ".config/nvim" = {
      enable = true;
      source = ./config/nvim;
      recursive = true;
    };
  };

  services.mako = {
    enable = true;
    defaultTimeout = "5";
  };
  services.blueman-applet = {
    enable = true;
    # enableBluetooth = true;
  };

  imports = [./nvf.nix];
  home.stateVersion = "25.05";
       home = {
         sessionVariables = {
           XMODIFIERS = "@im=fcitx";  # Example: for Fcitx input method
         };
       };
}

