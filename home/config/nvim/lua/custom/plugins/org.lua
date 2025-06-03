return {
  "chipsenkbeil/org-roam.nvim",
  tag = "0.1.1",
  dependencies = {
    {
      "nvim-orgmode/orgmode",
      tag = "0.3.7",
      event = "VeryLazy",
      layzy = true,
      ft = { "org" },
      config = function()
        -- Setup orgmode
        require("orgmode").setup {
          org_agenda_files = "~/org_roam/**/*",
          org_default_notes_file = "~/org_roam/refile.org",
        }

        -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
        -- add ~org~ to ignore_install
        require("nvim-treesitter.configs").setup {
          ignore_install = { "org" },
        }
      end,
    },
  },
  config = function()
    require("org-roam").setup {
      directory = "~/org_roam",
      -- optional
      --org_files = {
      --  "~/",
      --},
    }
  end,
}
