return {
  "jalvesaq/cmp-zotcite",
  config = function()
    require("cmp_zotcite").setup {
      filetypes = { "pandoc", "markdown", "rmd", "quarto" },
    }
    require("cmp").setup.buffer {
      sources = {
        { name = "cmp_zotcite" },
      },
    }
  end,
}
