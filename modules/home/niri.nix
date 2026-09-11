{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.waytrue.niri;
  focusZotero = pkgs.writeShellApplication {
    name = "niri-focus-zotero";
    runtimeInputs = [pkgs.jq pkgs.niri pkgs.zotero];
    text = ''
      window_id="$(
        niri msg -j windows \
          | jq -r 'map(select((.app_id // "") | test("^[Zz]otero$")) | .id) | first // empty'
      )"

      if [ -n "$window_id" ]; then
        exec niri msg action focus-window --id "$window_id"
      fi

      exec zotero
    '';
  };
in {
  options.waytrue.niri.enable = lib.mkEnableOption "Waytrue niri desktop configuration";

  config = lib.mkIf cfg.enable {
    #xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

    programs.niri.settings = {
      environment = {
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
      };
      outputs.DP-1 = {
        scale = 1.5;
      };
      spawn-at-startup = [
        {argv = ["nsticky"];}
        {argv = ["fcitx5"];}
      ];
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      workspaces = {
        "1" = {name = "term";};
        "2" = {name = "lit";};
        "3" = {name = "web";};
        "4" = {name = "dev";};
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
            {app-id = "^([Ll]ogseq|[Zz]otero)$";}
          ];
          open-on-workspace = "lit";
          open-focused = true;
        }
        {
          matches = [
            {app-id = "^(zen|zen-alpha)$";}
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
        "Mod+1".action.focus-workspace = "term";
        "Mod+2".action.focus-workspace = "lit";
        "Mod+3".action.focus-workspace = "web";
        "Mod+4".action.focus-workspace = "dev";
        "Mod+5".action.focus-workspace = "chat";
        "Mod+6".action.focus-workspace = "media";
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 0;
        "Mod+q".action = close-window;
        "Mod+e".action = toggle-overview;
        "Mod+Z" = {
          action.spawn = ["${focusZotero}/bin/niri-focus-zotero"];
          hotkey-overlay.title = "Focus Zotero";
        };

        "Mod+Return" = {
          action.spawn = ["kitty"];
          hotkey-overlay.title = "open kitty";
        };
        "Mod+Shift+M" = {
          action.spawn = ["nsticky" "sticky" "toggle-active"];
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
        "Print" = {
          action.screenshot = {};
          hotkey-overlay.title = "Screenshot";
        };
        "Ctrl+Print" = {
          action.screenshot-screen = {};
          hotkey-overlay.title = "Screenshot Screen";
        };
        "Alt+Print" = {
          action.screenshot-window = {};
          hotkey-overlay.title = "Screenshot Window";
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
          action.move-column-to-workspace = "term";
        };
        "Mod+Ctrl+2" = {
          action.move-column-to-workspace = "lit";
        };
        "Mod+Ctrl+3" = {
          action.move-column-to-workspace = "web";
        };
        "Mod+Ctrl+4" = {
          action.move-column-to-workspace = "dev";
        };
        "Mod+Ctrl+5" = {
          action.move-column-to-workspace = "chat";
        };
        "Mod+Ctrl+6" = {
          action.move-column-to-workspace = "media";
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

    programs.dank-material-shell = {
      enable = true;
      settings = {
        currentThemeName = lib.mkForce "dynamic";
        currentThemeCategory = "dynamic";
        matugenScheme = "scheme-rainbow";
      };
      niri = {
        enableKeybinds = true;
        enableSpawn = true; # Auto-start DMS with niri, if enabled
        includes = {
          enable = true; # Enable config includes hack. Enabled by default.

          override = true; # If disabled, DMS settings won't be prioritized over settings defined using niri-flake
          originalFileName = "hm"; # A new name (without extension) for the config file generated by niri-flake.
          filesToInclude = [
            # # Files under `$XDG_CONFIG_HOME/niri/dms` to be included into the new config
            "alttab" # Please note that niri will throw an error if any of these files are missing.
            "binds"
            "colors"
            "cursor"
            "layout"
            "outputs"
            "wpblur"
            "windowrules"
          ];
        };
      };
    };
    programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    services.mako.enable = false; # notification daemon
    services.swayidle.enable = true; # idle management daemon
    services.polkit-gnome.enable = false; # polkit
    home.packages = with pkgs; [
      swaybg # wallpaper
    ];
  };
}
