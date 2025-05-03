{ config, pkgs, lib,... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "waytrue";
  home.homeDirectory = "/home/waytrue";
  home.packages = with pkgs;[
	catppuccin-fcitx5
	fzf
	wpsoffice-cn
	inkscape
	fiji
	git
  ];

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



  };
  home.stateVersion = "25.05";
}
