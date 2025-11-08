-- 配置 tinymist LSP 服务器
vim.lsp.config('tinymist', {
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType",
    semanticTokens = "disable",
  },
})
-- 启用 tinymist LSP 服务器
vim.lsp.enable('tinymist')

-- typst-preview.nvim 插件配置保持不变
return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {},
}
