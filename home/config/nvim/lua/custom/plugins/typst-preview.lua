require("lspconfig")["tinymist"].setup {
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType",
    semanticTokens = "disable",
  },
}
return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {}, -- lazy.nvim will implicitly calls `setup {}`
}
