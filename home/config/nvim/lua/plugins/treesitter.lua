-- Customize Treesitter

--@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "r",
      "markdown",
      "markdown_inline",
      "rnoweb",
      "yaml",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
