local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- 获取当前日期（动态节点示例）
local function get_date() return os.date "%Y-%m-%d" end

-- 注册 Typst 片段
ls.add_snippets("typst", {
  -- 基础模板片段
  s("exp", {
    t { "*实验名称*:" },
    i(1, "Document Title"),
    t { "*实验目的*:" },
    i(2, "Document purpose"),
    t { "*实验内容及步骤*:" },
    i(3, "Document contents"),
    t { "*实验结果*:" },
    i(4, "Document contents"),
    i(0), -- 最终光标位置
  }),

  -- 数学公式片段
})
