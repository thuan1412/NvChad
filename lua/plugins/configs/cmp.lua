local present, cmp = pcall(require, "cmp")

if not present then
   return
end

vim.opt.completeopt = "menuone,noselect"

cmp.event:on('confirm_done', function ()
  -- get current location
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  print(r, c)
  -- check whether it's in a fucntion call
  -- check signature of function call
end)

-- nvim-cmp setup
cmp.setup {
   snippet = {
      expand = function(args)
         require("luasnip").lsp_expand(args.body)
      end,
   },
   formatting = {
      format = function(entry, vim_item)
         -- load lspkind icons
         vim_item.kind = string.format(
            "%s %s",
            require("plugins.configs.lspkind_icons").icons[vim_item.kind],
            vim_item.kind
         )

         vim_item.menu = ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            buffer = "[BUF]",
         })[entry.source.name]

         return vim_item
      end,
   },
   mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      -- ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      -- ["<CR>"] = cmp.mapping(function ()
      --   cmp.confirm({
      --      behavior = cmp.ConfirmBehavior.Replace,
      --      select = true,
      --   })
      -- end),
      -- function(fallback)
      --   print("confirm function is called", fallback)
      --   cmp.confirm {
      --      behavior = cmp.ConfirmBehavior.Replace,
      --      select = true,
      --   }
      -- end,
      ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ["<Tab>"] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ["<S-Tab>"] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
      -- setting for Copilot, don't know why it's set in here
      ["<C-space>"] = cmp.mapping(function()
        local copilot_keys = vim.fn["copilot#Accept"]()
        if copilot_keys ~= "" then
          vim.api.nvim_feedkeys(copilot_keys, "i", true)
        end
      end, {"i", "s"}),
   },
   sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "path" },
   },
}
