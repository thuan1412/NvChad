local utils = require "core.utils"
local hooks = require "core.hooks"

local config = utils.load_config()
local map = utils.map

local maps = config.mappings
local plugin_maps = maps.plugins
local nvChad_options = config.options.nvChad

local cmd = vim.cmd

local M = {}

-- these mappings will only be called during initialization
M.misc = function()
   local function non_config_mappings()
      -- Don't copy the replaced text after pasting in visual mode
      map("v", "p", '"_dP')

      -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
      -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
      -- empty mode is same as using :map
      -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
      map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
      map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
      map("", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
      map("", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

      -- vista toggle
      map("n", "<space>7", ":Vista!! <CR>")
      -- use ESC to turn off search highlighting
      map("n", "<Esc>", ":noh <CR>")

      -- use `gx` to open url
      if vim.fn.has("mac") == 1 then
        map('n', 'gx', ':call jobstart(["open", expand("<cfile>")], {"detach": v:true})<CR>', {})
      elseif vim.fn.has("unix") == 1 then
        map('n', 'gx', ':call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})<CR>', {})
      else
        map('n', 'gx', ':lua print("Error: gx is not supported on this OS!")<CR>', {})
      end

      map("n", "sg", ':lua require("custom.fn").sg_search()<CR>')
      map("v", "sg", ':lua require("custom.fn").sg_search()<CR>')

      -- TODO: <C-j>, <C-k> instead of <C-e>, <C-y>
      -- map("n", "<C-j>", "<C-e>")
      -- map("n", "<C-k>", "<C-e>")

      -- floating cmd window, fine-cmdline
      map('n', '<C-p>', ':lua require("fine-cmdline").open()<CR>')

      -- go.nvim mapping
      map('n', 'goc', ':GoCmt <CR>')
      map('n', 'gos', ':GoFillStruct <CR>')
   end

   local function optional_mappings()
      -- don't yank text on cut ( x )
      if not nvChad_options.copy_cut then
         map({ "n", "v" }, "x", '"_x')
      end

      -- don't yank text on delete ( dd )
      if not nvChad_options.copy_del then
         map({ "n", "v" }, "d", '"_d')
      end

      -- navigation within insert mode
      if nvChad_options.insert_nav then
         local inav = maps.insert_nav

         map("i", inav.backward, "<Left>")
         map("i", inav.end_of_line, "<End>")
         map("i", inav.forward, "<Right>")
         map("i", inav.next_line, "<Up>")
         map("i", inav.prev_line, "<Down>")
         map("i", inav.beginning_of_line, "<ESC>^i")
      end

      -- easier navigation between windows
      if nvChad_options.window_nav then
         local wnav = maps.window_nav

         map("n", wnav.moveLeft, "<C-w>h")
         map("n", wnav.moveRight, "<C-w>l")
         map("n", wnav.moveUp, "<C-w>k")
         map("n", wnav.moveDown, "<C-w>j")
      end

      -- check the theme toggler
      if nvChad_options.theme_toggler then
         map(
            "n",
            maps.theme_toggler,
            ":lua require('nvchad').toggle_theme(require('core.utils').load_config().ui.theme_toggler) <CR>"
         )
      end
   end

   local function required_mappings()
      map("n", maps.close_buffer, ":lua require('core.utils').close_buffer() <CR>") -- close  buffer
      map("n", maps.copy_whole_file, ":%y+ <CR>") -- copy whole file content
      map("n", maps.new_buffer, ":enew <CR>") -- new buffer
      map("n", maps.new_tab, ":tabnew <CR>") -- new tabs
      map("n", maps.line_number_toggle, ":set nu! <CR>") -- toggle numbers
      map("n", maps.save_file, ":w <CR>") -- ctrl + s to save file

      -- terminal mappings --
      local term_maps = maps.terminal
      -- get out of terminal mode
      map("t", term_maps.esc_termmode, "<C-\\><C-n>")
      -- hide a term from within terminal mode
      map("t", term_maps.esc_hide_termmode, "<C-\\><C-n> :lua require('core.utils').close_buffer() <CR>")
      -- pick a hidden term
      map("n", term_maps.pick_term, ":Telescope terms <CR>")
      -- Open terminals
      map("n", term_maps.new_horizontal, ":execute 15 .. 'new +terminal' | let b:term_type = 'hori' | startinsert <CR>")
      map("n", term_maps.new_vertical, ":execute 'vnew +terminal' | let b:term_type = 'vert' | startinsert <CR>")
      map("n", term_maps.new_window, ":execute 'terminal' | let b:term_type = 'wind' | startinsert <CR>")
      -- terminal mappings end --

      -- Add Packer commands because we are not loading it at startup
      cmd "silent! command PackerClean lua require 'plugins' require('packer').clean()"
      cmd "silent! command PackerCompile lua require 'plugins' require('packer').compile()"
      cmd "silent! command PackerInstall lua require 'plugins' require('packer').install()"
      cmd "silent! command PackerStatus lua require 'plugins' require('packer').status()"
      cmd "silent! command PackerSync lua require 'plugins' require('packer').sync()"
      cmd "silent! command PackerUpdate lua require 'plugins' require('packer').update()"

      -- add NvChadUpdate command and mapping
      cmd "silent! command! NvChadUpdate lua require('nvchad').update_nvchad()"
      map("n", maps.update_nvchad, ":NvChadUpdate <CR>")

      -- add ChadReload command and maping
      -- cmd "silent! command! NvChadReload lua require('nvchad').reload_config()"
   end

   non_config_mappings()
   optional_mappings()
   required_mappings()
   hooks.run("setup_mappings", map)
end

-- below are all plugin related mappings

M.bufferline = function()
  local m = plugin_maps.bufferline

  -- map("n", m.next_buffer, ":BufferLineCycleNext <CR>")
  -- map("n", m.prev_buffer, ":BufferLineCyclePrev <CR>")

  map("n", "<leader>c", ":bdelete<CR>")

  map("n", "<leader>1", ":BufferLineGoToBuffer 1<CR>")
  map("n", "<leader>2", ":BufferLineGoToBuffer 2<CR>")
  map("n", "<leader>3", ":BufferLineGoToBuffer 3<CR>")
  map("n", "<leader>4", ":BufferLineGoToBuffer 4<CR>")
  map("n", "<leader>5", ":BufferLineGoToBuffer 5<CR>")
  map("n", "<leader>6", ":BufferLineGoToBuffer 6<CR>")
  map("n", "<leader>7", ":BufferLineGoToBuffer 7<CR>")
  map("n", "<leader>8", ":BufferLineGoToBuffer 8<CR>")
  map("n", "<leader>9", ":BufferLineGoToBuffer 9<CR>")
end

-- M.comment = function()
--    local m = plugin_maps.comment.toggle
--    map("n", m, ":CommentToggle <CR>")
--    map("v", m, ":CommentToggle <CR>")
-- end

M.dashboard = function()
   local m = plugin_maps.dashboard

   map("n", m.bookmarks, ":DashboardJumpMarks <CR>")
   map("n", m.new_file, ":DashboardNewFile <CR>")
   map("n", m.open, ":Dashboard <CR>")
   map("n", m.session_load, ":SessionLoad <CR>")
   map("n", m.session_save, ":SessionSave <CR>")
end

M.nvimtree = function()
   local m = plugin_maps.nvimtree

   map("n", m.toggle, ":NvimTreeToggle <CR>")
   -- TODO: cannot call nvim-tree outside the actual nvimtree :)
   -- map("n", m.copy_absolute_path, ":lua require('nvim-tree').on_keypress('copy_absolute_path') <CR>")
   -- map("n", m.copy_path, ":lua require('nvim-tree').on_keypress('copy_path') <CR>")
   -- map("n", m.copy_name, ":lua require('nvim-tree').on_keypress('copy_name') <CR>")
end

M.telescope = function()
   local m = plugin_maps.telescope

   map("n", m.open, ":Telescope <CR>")
   map("n", m.keymaps, ":Telescope keymaps<CR>")
   map("n", m.buffers, ":Telescope buffers <CR>")
   map("n", m.code_actions, ":Telescope lsp_code_actions <CR>")
   map("n", m.find_files, ":Telescope find_files <CR>")
   map("n", m.find_hiddenfiles, ":Telescope find_files hidden=true <CR>")
   map("n", m.git_commits, ":Telescope git_commits <CR>")
   map("n", m.git_status, ":Telescope git_status <CR>")
   map("n", m.help_tags, ":Telescope help_tags <CR>")
   map("n", m.live_grep, ":Telescope live_grep <CR>")
   map("n", m.oldfiles, ":Telescope oldfiles only_cwd=true} <CR>")
   map("n", m.dynamic_symbols, ":Telescope lsp_dynamic_workspace_symbols <CR>")
   map("n", m.themes, ":Telescope themes <CR>")
end

M.telescope_media = function()
   local m = plugin_maps.telescope.telescope_media

   map("n", m.media_files, ":Telescope media_files <CR>")
end

return M
