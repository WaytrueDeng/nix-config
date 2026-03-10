{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  #xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  programs.niri.settings = {
    spawn-at-startup = [
      {argv = ["nsticky"];}
    ];

    workspaces = {
      "1" = {name = "term";};
      "2" = {name = "dev";};
      "3" = {name = "web";};
      "4" = {name = "lit";};
      "5" = {name = "chat";};
      "6" = {name = "media";};
    };
    window-rules = [
      {
        matches = [
          {app-id = "^(Alacritty|foot|kitty|wezterm)$";}
        ];
        open-on-workspace = "term";
      }
      {
        matches = [
          {app-id = "^(firefox|microsoft-edge)$";}
        ];
        open-on-workspace = "web";
        open-focused = true;
      }
    ];
    input.workspace-auto-back-and-forth = true;
    input.keyboard.xkb = {
      options = "caps:swapescape";
    };
    prefer-no-csd = true;
    binds = with config.lib.niri.actions; {
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+0".action.focus-workspace = 0;
      "Mod+q".action = close-window;
      "Mod+e".action = toggle-overview;

      "Mod+Return" = {
        action.spawn = ["kitty"];
        hotkey-overlay.title = "open kitty";
      };
      "Mod+Shift+M" = {
        action.spawn = ["nsticky" "toggle-active"];
        hotkey-overlay.title = "toggle sticky";
      };
      "Mod+A" = {
        action = focus-window-up-or-column-left;
        hotkey-overlay.title = "Focus Previous Window";
      };
      "Mod+Ctrl+A" = {
        action = move-column-left;
        hotkey-overlay.title = "Focus Previous Window";
      };
      "Mod+D" = {
        action = focus-window-up-or-column-right;
        hotkey-overlay.title = "Focus next Window";
      };
      "Mod+Ctrl+D" = {
        action = move-column-right;
        hotkey-overlay.title = "Focus next Window";
      };
      "Mod+F" = {
        action = maximize-column;
        hotkey-overlay.title = "Toggle Fullscreen";
      };
      "Mod+Shift+Space" = {
        action.spawn = ["rofi" "-show" "window"];
        hotkey-overlay.title = "Toggle Fullscreen";
      };
      "Mod+Shift+F" = {
        action = toggle-window-floating;
        hotkey-overlay.title = "Toggle Fullscreen";
      };
      "Mod+Ctrl+F" = {
        action = fullscreen-window;
        hotkey-overlay.title = "Toggle Fullscreen";
      };
      "Mod+K" = {
        action = focus-workspace-up;
        hotkey-overlay.title = "Focus Workspace Up";
      };
      "Mod+J" = {
        action = focus-workspace-down;
        hotkey-overlay.title = "Focus Workspace Down";
      };
      "Mod+R" = {
        action = switch-preset-column-width;
        hotkey-overlay.title = "switch-preset-column-width";
      };
      "Mod+Ctrl+1" = {
        action.move-column-to-workspace = 1;
      };
      "Mod+Ctrl+2" = {
        action.move-column-to-workspace = 2;
      };
      "Mod+Ctrl+3" = {
        action.move-column-to-workspace = 3;
      };
      "Mod+Ctrl+4" = {
        action.move-column-to-workspace = 4;
      };
      "Mod+Ctrl+5" = {
        action.move-column-to-workspace = 5;
      };
      "Mod+Ctrl+6" = {
        action.move-column-to-workspace = 6;
      };
      "Mod+Ctrl+7" = {
        action.move-column-to-workspace = 7;
      };
      "Mod+Ctrl+8" = {
        action.move-column-to-workspace = 8;
      };
      "Mod+Ctrl+9" = {
        action.move-column-to-workspace = 9;
      };
    };
  };
  programs.dankMaterialShell = {
    enable = true;
    niri = {
      #enableKeybinds = true; # Automatic keybinding configuration
      enableSpawn = true; # Auto-start DMS with niri
      #includes.enable = false;
    };
  };
  programs.alacritty.enable = true; # Super+T in the default setting (terminal)
  programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
  programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
  programs.waybar.enable = true; # launch on startup in the default setting (bar)
  services.mako.enable = true; # notification daemon
  services.swayidle.enable = true; # idle management daemon
  services.polkit-gnome.enable = true; # polkit
  home.packages = with pkgs; [
    swaybg # wallpaper
  ];
}
