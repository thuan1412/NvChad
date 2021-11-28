local present, ls = pcall(require, "luasnip")
local chadrc_config = require("core.utils").load_config()

print("tai sao may` lai k dc in ra")
-- if not present then
--   return
-- end
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}

local snippets = {}

-- https://github.com/L3MON4D3/LuaSnip/blob/f400b978b1dbca96e9e190b7009c415c09b8924c/Examples/snippets.lua#L40
-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
	return args[1]
end

-- stole from tj
local shortcut = function(val)
  if type(val) == "string" then
    return { t { val }, i(0) }
  end

  if type(val) == "table" then
    for k, v in ipairs(val) do
      if type(v) == "string" then
        val[k] = t { v }
      end
    end
  end

  return val
end

-- stole from tj
local make = function(tbl)
  local result = {}
  for k, v in pairs(tbl) do
    table.insert(result, (s({ trig = k, desc = v.desc }, shortcut(v))))
  end

  return result
end

snippets.all = make {
  -- trigger is fn.
  fn = {
    -- Simple static text.
    t("//Parameters: "),
    -- function, first parameter is the function, second the Placeholders
    -- whose text it gets as input.
    f(copy, 2),
    t({ "", "function " }),
    -- Placeholder/Insert.
    i(1),
    t("("),
    -- Placeholder with initial text.
    i(2, "int foo"),
    -- Linebreak
    t({ ") {", "\t" }),
    -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
    i(0),
    t({ "", "}" }),
  },
  pwd = {
    t { vim.fn.expand("%:p:h") }
  },
}

-- stole from tj
snippets.go = make {
  p0 = {
    t { 'fmt.Println("=====================")' },
    i(0)
  },
  fp0 = {
    t { 'fmt.Println("=====================")' },
    i(0)
  },
  fpv = {
    t { 'fmt.Println('},
    i(0),
    t {')'}
  },
  fn = {
    -- Simple static text.
    t("//Parameters: "),
    -- function, first parameter is the function, second the Placeholders
    -- whose text it gets as input.
    f(copy, 2),
    t({ "", "function " }),
    -- Placeholder/Insert.
    i(1),
    t("("),
    -- Placeholder with initial text.
    i(2, "int foo"),
    -- Linebreak
    t({ ") {", "\t" }),
    -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
    i(0),
    t({ "", "}" }),
  }
}

snippets.lua = make {
  p0 = {
    t { 'print("=====================")' },
    i(0)
  }
}


ls.snippets = snippets

require("luasnip/loaders/from_vscode").load { paths = chadrc_config.plugins.options.luasnip.snippet_path }
require("luasnip/loaders/from_vscode").load()
