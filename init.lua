local ok, err = pcall(require, "core")

if not ok then
   error("Error loading core" .. "\n\n" .. err)
end
vim.api.nvim_set_keymap("n", "<leader>s", ":noa update<CR>", {noremap = true, silent = true})
require("plugins.configs.comment")
