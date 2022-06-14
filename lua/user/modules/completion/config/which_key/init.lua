R("user.modules.completion.config.which_key.config")

return function()
  rvim.which_key = {
    setup = {
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
        spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
      },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      window = {
        border = rvim.style.border.current,
      },
      layout = {
        align = "center",
      },
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
      show_help = true, -- show help message on the command line when the popup is visible
    },

    leader_opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    localleader_opts = {
      mode = "n", -- NORMAL mode
      prefix = "<localleader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    vopts = {
      mode = "v", -- VISUAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
    -- see https://neovim.io/doc/user/map.html#:map-cmd
    vmappings = {},
    mappings = {},
  }

  local which_key = require("which-key")

  which_key.setup(rvim.which_key.setup)

  -- Set default keymaps
  vim.g.which_key_map = rvim.wk.leader_mode

  -- Get Which-Key keymap
  local key_maps = vim.g.which_key_map
  local plugin_keymaps = rvim.wk.plugin

  -- git
  if rvim.plugins.tools.telescope.active and rvim.plugins.ui.git_signs.active then
    key_maps.g = plugin_keymaps.git
  end

  -- lsp
  if rvim.plugin_loaded("nvim-lspconfig") then
    key_maps.l = plugin_keymaps.lsp
  end

  -- packer
  if rvim.plugins.packer.active then
    key_maps.p = plugin_keymaps.packer
  end

  -- Register keymaps
  local leader_opts = rvim.which_key.leader_opts
  local vopts = rvim.which_key.vopts
  local localleader_opts = rvim.which_key.localleader_opts

  which_key.register(key_maps, leader_opts)
  which_key.register(rvim.wk.visual_mode, vopts)
  which_key.register(rvim.wk.normal_mode)
  which_key.register(rvim.wk.localleader, localleader_opts)

  rvim.augroup("WhichKeyMode", {
    {
      event = { "FileType" },
      pattern = { "which_key" },
      command = "set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2",
    },
  })
end
