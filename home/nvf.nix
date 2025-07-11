{
  lib,
  pkgs,
  ...
}: let
  isMaximal = true;
in {
  programs.nvf = {
    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;
        debugMode = {
          enable = false;
          level = 16;
          logFile = "/tmp/nvim.log";
        };

        keymaps = [
          {
            key = "<C-'>";
            mode = ["n" "x" "t"];
            silent = true;
            action = "<cmd>ToggleTerm<CR>";
          }
        ];

        spellcheck = {
          enable = true;
        };

        lsp = {
          formatOnSave = true;
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = false;
          trouble.enable = true;
          lspSignature.enable = !isMaximal; # conflicts with blink in maximal
          otter-nvim.enable = isMaximal;
          nvim-docs-view.enable = isMaximal;
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        # This section does not include a comprehensive list of available language modules.
        # To list all available language module options, please visit the nvf manual.
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          # Languages that will be supported in default and maximal configurations.
          nix.enable = true;
          markdown.enable = true;
          # Languages that are enabled in the maximal configuration.
          bash.enable = isMaximal;
          clang.enable = isMaximal;
          css.enable = isMaximal;
          html.enable = isMaximal;
          sql.enable = isMaximal;
          lua.enable = isMaximal;
          python.enable = isMaximal;
          typst.enable = isMaximal;
          rust = {
            enable = isMaximal;
            crates.enable = isMaximal;
          };

          # Language modules that are not as common.
          nu.enable = true;
          r.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = isMaximal;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline.enable = true;

          # Fun
          cellular-automaton.enable = false;
        };

        statusline = {
          lualine = {
            enable = true;
            theme = lib.mkForce "catppuccin";
          };
        };

        theme = {
          enable = true;
          name = lib.mkForce "catppuccin";
          style = lib.mkForce "mocha";
          transparent = lib.mkForce true;
        };

        autopairs.nvim-autopairs.enable = true;

        # nvf provides various autocomplete options. The tried and tested nvim-cmp
        # is enabled in default package, because it does not trigger a build. We
        # enable blink-cmp in maximal because it needs to build its rust fuzzy
        # matcher library.
        autocomplete = {
          nvim-cmp.enable = !isMaximal;
          blink-cmp.enable = isMaximal;
        };

        snippets.luasnip.enable = true;

        filetree = {
          neo-tree = {
            enable = true;
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
          hardtime-nvim.enable = false;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
        };

        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = isMaximal; # lighter, faster, and uses lua for configuration
        };

        dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = isMaximal;
        };

        notify = {
          nvim-notify.enable = true;
        };

        projects = {
          project-nvim.enable = isMaximal;
        };

        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim.enable = false;
          icon-picker.enable = isMaximal;
          surround.enable = isMaximal;
          leetcode-nvim.enable = isMaximal;
          multicursors.enable = isMaximal;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = isMaximal;
          };
          images = {
            image-nvim.enable = false;
          };
        };

        notes = {
          obsidian.enable = false; # FIXME: neovim fails to build if obsidian is enabled
          neorg.enable = false;
          orgmode.enable = false;
          mind-nvim.enable = isMaximal;
          todo-comments.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          modes-nvim.enable = false; # the theme looks terrible with catppuccin
          illuminate.enable = true;
          breadcrumbs = {
            enable = isMaximal;
            navbuddy.enable = isMaximal;
          };
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              # this is a freeform module, it's `buftype = int;` for configuring column position
              nix = "110";
              ruby = "120";
              java = "130";
              go = ["90" "130"];
            };
          };
          fastaction.enable = true;
        };

        assistant = {
          chatgpt.enable = false;
          copilot = {
            enable = false;
            cmp.enable = isMaximal;
          };
          codecompanion-nvim.enable = false;
        };

        session = {
          nvim-session-manager.enable = false;
        };

        gestures = {
          gesture-nvim.enable = false;
        };

        comments = {
          comment-nvim.enable = true;
        };

        presence = {
          neocord.enable = false;
        };
      };
    };
  };
}
