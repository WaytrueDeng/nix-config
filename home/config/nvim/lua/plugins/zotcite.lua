return {
  {
    "jalvesaq/zotcite",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("zotcite").setup {
        -- your options here (see doc/zotcite.txt)
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        sync_install = true,
        ensure_installed = {
          "html",
          "latex",
          "markdown",
          "markdown_inline",
          "yaml",
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      }
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "nvim_treesitter#foldexpr()"
      vim.o.foldenable = false
    end,
  },
}
