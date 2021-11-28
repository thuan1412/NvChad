local M = {}

M.sg_search = function ()
  local word = ""
  local mode = vim.fn.mode()
  if mode == "n" then
    word = vim.fn.expand("<cword>")
  elseif mode == "v" then
   -- https://github.com/neovim/neovim/pull/13896/files
    word = vim.fn.expand("<cword>")
  end
  local filetype = vim.bo.filetype
  local sg_url = "https://sourcegraph.com/search?q=context:global+" .. word .. "+lang:" .. filetype
  vim.cmd('exec "!xdg-open \'' .. sg_url .. '\'"')
end

return M
