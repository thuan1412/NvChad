local M = {}

M.setup_lsp = function(attach, capabilities)
  local lspconfig = require "lspconfig"

  lspconfig.html.setup {
    on_attach = attach,
    capabilities = capabilities,
  }

  lspconfig.tsserver.setup {
    on_attach = attach,
    capabilities = capabilities,
  }

  require'lspconfig'.gopls.setup {
    cmd = { "gopls" },
    settings = {gopls = {analyses = {unusedparams = true}, staticcheck = true}},
    root_dir = require'lspconfig'.util.root_pattern(".git", "go.mod", "."),
    init_options = { usePlaceholders = true, completeUnimported = true },
    on_attach = attach,
    capabilities = capabilities,
  }

  require'lspconfig'.pyright.setup{
    on_attach = attach,
    capabilities = capabilities,
  }

  -- lspconfig.vuels.setup {
  --   on_attach = attach,
  --   capabilities = capabilities,
  -- }

end

return M
