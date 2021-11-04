local ok, err = pcall(require, "core")

if not ok then
   error("Error loading core" .. "\n\n" .. err)
end
vim.api.nvim_set_keymap("n", "<leader>s", ":noa update<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>f", ":Neoformat <CR>", {noremap = true, silent = true})

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

-- ["<C-y>"] = cmp.mapping(function()
--   local copilot_keys = vim.fn["copilot#Accept"]()
--   if copilot_keys ~= "" then
--     vim.api.nvim_feedkeys(copilot_keys, "i", true)
--   end
-- end, {"i", "s"}),
require("plugins.configs.comment")
