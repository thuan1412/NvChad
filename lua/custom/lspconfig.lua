local M = {}

M.setup_lsp = function(attach, capabilities)
  local lspconfig = require "lspconfig"

  lspconfig.html.setup {
    on_attach = attach,
    capabilities = capabilities,
  }

  require'lspconfig'.gopls.setup {
    cmd = { "gopls" },
    settings = {gopls = {analyses = {unusedparams = true}, staticcheck = true}},
    root_dir = require'lspconfig'.util.root_pattern(".git", "go.mod", "."),
    init_options = { usePlaceholders = true, completeUnimported = true },
    -- on_attach = require'lsp'.common_on_attach,
    -- capabilities = require'lsp'.common_capabilities
  }

  end

  return M
