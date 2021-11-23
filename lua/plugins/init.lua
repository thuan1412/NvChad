local present, packer = pcall(require, "plugins.packerInit")

if not present then
   return false
end

local use = packer.use

return packer.startup(function()
   local status = require("core.utils").load_config().plugins.status

   -- FUNCTION: override_req, use `chadrc` plugin config override if present
   -- name = name inside `default_config` / `chadrc`
   -- default_req = run this if 'name' does not exist in `default_config` / `chadrc`
   -- if override or default_req start with `(`, then strip that and assume override calls a function, not a whole file
   local override_req = function(name, default_req)
      local override = require("core.utils").load_config().plugins.default_plugin_config_replace[name]
      local result

      if override == nil then
         result = default_req
      else
         result = override
      end

      if string.match(result, "^%(") then
         result = result:sub(2)
         result = result:gsub("%)%.", "').", 1)
         return "require('" .. result
      else
         return "require('" .. result .. "')"
      end
   end

   -- this is arranged on the basis of when a plugin starts

   -- this is the nvchad core repo containing utilities for some features like theme swticher, no need to lazy load
   use {
      "Nvchad/extensions",
   }

   use {
      "nvim-lua/plenary.nvim",
   }

   use {
      "wbthomason/packer.nvim",
      event = "VimEnter",
   }

   use {
      "NvChad/nvim-base16.lua",
      after = "packer.nvim",
      config = function()
         require("colors").init()
      end,
   }

   use {
      "kyazdani42/nvim-web-devicons",
      after = "nvim-base16.lua",
      config = override_req("nvim_web_devicons", "plugins.configs.icons"),
   }

   use {
      "famiu/feline.nvim",
      disable = not status.feline,
      after = "nvim-web-devicons",
      config = override_req("feline", "plugins.configs.statusline"),
   }

   use {
      "akinsho/bufferline.nvim",
      disable = not status.bufferline,
      after = "nvim-web-devicons",
      config = override_req("bufferline", "plugins.configs.bufferline"),
      setup = function()
         require("core.mappings").bufferline()
      end,
   }

   use {
      "lukas-reineke/indent-blankline.nvim",
      disable = not status.blankline,
      event = "BufRead",
      config = override_req("indent_blankline", "(plugins.configs.others).blankline()"),
   }

   use {
      "norcalli/nvim-colorizer.lua",
      disable = not status.colorizer,
      event = "BufRead",
      config = override_req("nvim_colorizer", "(plugins.configs.others).colorizer()"),
   }

   use {
      "nvim-treesitter/nvim-treesitter",
      branch = "0.5-compat",
      event = "BufRead",
      config = override_req("nvim_treesitter", "plugins.configs.treesitter"),
   }

   -- git stuff
   use {
      "lewis6991/gitsigns.nvim",
      disable = not status.gitsigns,
      opt = true,
      config = override_req("gitsigns", "plugins.configs.gitsigns"),
      setup = function()
         require("core.utils").packer_lazy_load "gitsigns.nvim"
      end,
   }

   -- lsp stuff

   use {
      "neovim/nvim-lspconfig",
      opt = true,
      setup = function()
         require("core.utils").packer_lazy_load "nvim-lspconfig"
         -- reload the current file so lsp actually starts for it
         vim.defer_fn(function()
            vim.cmd 'if &ft == "packer" | echo "" | else | silent! e %'
         end, 0)
      end,
      config = override_req("lspconfig", "plugins.configs.lspconfig"),
   }

   use {
      "ray-x/lsp_signature.nvim",
      disable = not status.lspsignature,
      after = "nvim-lspconfig",
      config = override_req("signature", "(plugins.configs.others).signature()"),
   }

   use {
      "andymass/vim-matchup",
      disable = not status.vim_matchup,
      opt = true,
      setup = function()
         require("core.utils").packer_lazy_load "vim-matchup"
      end,
   }

   use {
      "max397574/better-escape.nvim",
      disable = not status.esc_insertmode,
      event = "InsertEnter",
      config = override_req("better_escape", "(plugins.configs.others).better_escape()"),
   }

   -- load luasnips + cmp related in insert mode only

   use {
      "rafamadriz/friendly-snippets",
      disable = not status.cmp,
      event = "InsertEnter",
   }

   use {
      "hrsh7th/nvim-cmp",
      disable = not status.cmp,
      after = "friendly-snippets",
      config = override_req("nvim_cmp", "plugins.configs.cmp"),
   }

   use {
      "L3MON4D3/LuaSnip",
      disable = not status.cmp,
      wants = "friendly-snippets",
      after = "nvim-cmp",
      config = override_req("luasnip", "(plugins.configs.others).luasnip()"),
   }

   use {
      "saadparwaiz1/cmp_luasnip",
      disable = not status.cmp,
      after = "LuaSnip",
   }

   use {
      "hrsh7th/cmp-nvim-lua",
      disable = not status.cmp,
      after = "cmp_luasnip",
   }

   use {
      "hrsh7th/cmp-nvim-lsp",
      disable = not status.cmp,
      after = "cmp-nvim-lua",
   }

   use {
      "hrsh7th/cmp-buffer",
      disable = not status.cmp,
      after = "cmp-nvim-lsp",
   }

   use {
      "hrsh7th/cmp-path",
      disable = not status.cmp,
      after = "cmp-buffer",
   }
   -- misc plugins
   use {
      "windwp/nvim-autopairs",
      disable = not status.autopairs,
      after = "nvim-cmp",
      config = override_req("nvim_autopairs", "(plugins.configs.others).autopairs()"),
   }

   use {
      "glepnir/dashboard-nvim",
      disable = not status.dashboard,
      config = override_req("dashboard", "plugins.configs.dashboard"),
      setup = function()
         require("core.mappings").dashboard()
      end,
   }

   use {
      "numToStr/Comment.nvim",
      config = override_req("Comment", "plugins.configs.comment"),
    }

   -- file managing , picker etc
   use {
      "kyazdani42/nvim-tree.lua",
      disable = not status.nvimtree,
      cmd = { "NvimTreeToggle", "NvimTreeFocus" },
      config = override_req("nvim_tree", "plugins.configs.nvimtree"),
      setup = function()
         require("core.mappings").nvimtree()
      end,
   }
   use {
      "nvim-telescope/telescope.nvim",
      module = "telescope",
      cmd = "Telescope",
      requires = {
         {
            "nvim-telescope/telescope-fzf-native.nvim",
            run = "make",
         },
         {
            "nvim-telescope/telescope-media-files.nvim",
            disable = not status.telescope_media,
            setup = function()
               require("core.mappings").telescope_media()
            end,
         },
      },
      config = override_req("telescope", "plugins.configs.telescope"),
      setup = function()
         require("core.mappings").telescope()
      end,
   }

   -- use {
   --    "/home/thuando/code/nvim/telescope.nvim",
   --    module = "telescope",
   --    cmd = "Telescope",
   --    requires = {
   --       {
   --          "nvim-telescope/telescope-fzf-native.nvim",
   --          run = "make",
   --       },
   --       {
   --          "nvim-telescope/telescope-media-files.nvim",
   --          disable = not status.telescope_media,
   --          setup = function()
   --             require("core.mappings").telescope_media()
   --          end,
   --       },
   --    },
   --    config = override_req("telescope", "plugins.configs.telescope"),
   --    setup = function()
   --       require("core.mappings").telescope()
   --    end,
   -- }

    use {
      "luukvbaal/stabilize.nvim",
      config = function() require("stabilize").setup() end
    }

    use {
      "github/copilot.vim"
    }

    -- tpope --
    use 'tpope/vim-abolish'
    use 'tpope/vim-repeat'
    use 'tpope/vim-speeddating'
    use 'tpope/vim-surround'
    use 'tpope/vim-unimpaired'
    use 'tpope/vim-dadbod'

    -- file outline
   use {
      'liuchengxu/vista.vim',
   }
	-- code format
	use { 'sbdchd/neoformat' }
   ---use {
   ---  "fatih/vim-go"
   ---}

   -- TODO: install later
  -- mhartington/dotfiles is the dotfiles of the vim for frontend author
  -- use mhartington/formatter-nvim
  use 'TimUntersberger/neogit'
  use 'mattn/emmet-vim'
  -- use octo - github integraion - nice
  -- use package-info.nvim

  use {
    "williamboman/nvim-lsp-installer",
    config = function()
      local lsp_installer = require "nvim-lsp-installer"
      lsp_installer.on_server_ready(function(server)
        local opts = {}
          server:setup(opts)
          vim.cmd [[ do User LspAttachBuffers ]]
        end)
      end,
    }

  -- debugging
  use 'mfussenegger/nvim-dap'
  -- use 'nvim-telescope/telescope-dap.nvim'
  use 'rcarriga/nvim-dap-ui'

  -- go dev
  use "buoto/gotests-vim"

  -- floating command window
  use {
    'VonHeikemen/fine-cmdline.nvim',
    requires = {
      {'MunifTanjim/nui.nvim'}
    }
  }

  use {
    'tjdevries/sg.nvim',
    commit = '76354e9f0b6de39134ec9efcd022f079ae0ce02b',
    after = 'nvim-lspconfig'
  }

  require("core.hooks").run("install_plugins", use)
end)
