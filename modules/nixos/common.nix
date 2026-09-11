{
  config,
  inputs,
  lib,
  pkgs,
  pkgs-stable,
  ...
}: let
  appimageRun = pkgs.appimage-run.override {
    extraPkgs = pkgs: [pkgs.libxshmfence];
  };
in {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.niri.enable = true;
  systemd.user.services.niri-flake-polkit.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "clash-verge-rev-unwrapped-2.2.3"
    "clash-verge-rev-2.2.3"
    "electron-33.4.11"
  ];

  nix.settings.substituters = ["https://mirrors.ustc.edu.cn/nix-channels/store"];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["waytrue"];

  networking.networkmanager.enable = true;
  networking = {
    nameservers = ["223.5.5.5"];
    networkmanager.dns = "none";
  };
  networking.firewall.enable = false;

  time.timeZone = "Asia/Shanghai";

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [
    {
      users = ["waytrue"];
      keepEnv = true;
      persist = true;
    }
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-code-pro
      hack-font
      jetbrains-mono
      lxgw-wenkai
    ];
    fontconfig.defaultFonts = {
      emoji = ["Noto Color Emoji"];
      monospace = [
        "Noto Sans Mono CJK SC"
        "Sarasa Mono SC"
        "DejaVu Sans Mono"
      ];
      sansSerif = [
        "Noto Sans CJK SC"
        "Source Han Sans SC"
        "DejaVu Sans"
      ];
      serif = [
        "Noto Serif CJK SC"
        "Source Han Serif SC"
        "DejaVu Serif"
      ];
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
      kdePackages.fcitx5-qt
      rime-data
    ];
  };

  services.xserver.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Input.ClassicBondedOnly = false;
      Policy.AutoEnable = true;
    };
  };
  services.blueman.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.flatpak.enable = true;
  services.libinput.enable = true;
  services.udisks2.enable = true;
  services.tlp = {
    enable = true;
    settings.STOP_CHARGE_THRESH_BAT0 = 1;
  };

  programs.zsh.enable = true;
  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
  };
  programs.thunar.enable = true;

  users.users.waytrue = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "users"];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
  };

  environment.systemPackages = with pkgs;
    [
      vim
      wget
      vscode
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      wl-clipboard
      gcc
      git
      acpi
      cargo
      rustc
      appimageRun
      nerd-fonts.fira-code
      pavucontrol
      tree-sitter
      kanshi
      (inputs.nsticky.packages.${pkgs.system}.nsticky)
    ]
    ++ (with pkgs-stable; [
      # wineWowPackages.stable
      # winetricks
    ]);

  virtualisation.docker.enable = true;
  system.stateVersion = "25.05";

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.useUserPackages = true;
  home-manager.users.waytrue = {
    imports = [
      ../../home/home.nix
      inputs.nvf.homeManagerModules.default
      inputs.niri.homeModules.niri
      inputs.dankMaterialShell.homeModules.dank-material-shell
      inputs.dankMaterialShell.homeModules.niri
    ];
  };
}
