local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- 获取当前日期（动态节点示例）
local function get_date() return os.date "%Y-%m-%d" end

-- 注册 Typst 片段
ls.add_snippets("typst", {
  -- 基础模板片段
  s(
    "exp",
    fmt(
      [[
*实验名称*: {}

*实验目的*: {}

*实验内容及步骤*: {}

*实验结果*: 
{}
#line(
length: 100%,
stroke: 2pt + maroon,
)

  ]],
      {
        i(1, "Document Title"), -- 实验名称插入点
        i(2, "Document purpose"), -- 实验目的插入点
        i(3, "Document contents"), -- 内容步骤插入点
        i(4, "Document contents"), -- 实验结果插入点
      }
    )
  ),

  s("table", {
    t "#figure(caption: [",
    i(1, "caption"),
    t "])[",
    t { "", "#set text(size: 6pt)", "#three-line-table[" },
    i(0), -- 表格内容
    t { "", "]", "]" },
  }),
  s("grid", t { "#grid(", "columns: 2,", "align: bottom,", "[],", "[])" }),
  -- 数学公式片段
})

return {}
