local vim = vim
local g = vim.g
local cmd = vim.cmd
local mappings = require('utils.map')
local nnoremap = mappings.nnoremap
local config = {}

function config.illuminate()
  vim.g.Illuminate_ftblacklist = { 'javascript', 'typescript', 'jsx', 'tsx', 'html' }
end

function config.colorizer()
  require 'colorizer'.setup(
      {'*';},
      {
        RGB      = true;         -- #RGB hex codes
        RRGGBB   = true;         -- #RRGGBB hex codes
        names    = false;         -- "Name" codes like Blue
        RRGGBBAA = true;         -- #RRGGBBAA hex codes
        rgb_fn   = true;         -- CSS rgb() and rgba() functions
        hsl_fn   = true;         -- CSS hsl() and hsla() functions
        css      = true;         -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn   = true;         -- Enable all CSS *functions*: rgb_fn, hsl_fn
      }
  )
end

function config.nvim_tree()
  g.nvim_tree_side = 'right'
  g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
  g.nvim_tree_quit_on_open = 0
  g.nvim_tree_hide_dotfiles = 0
  g.nvim_tree_follow = 1
  g.nvim_tree_indent_markers = 1
  g.nvim_tree_root_folder_modifier = ':~'
  g.nvim_tree_tab_open = 1
  g.nvim_tree_width_allow_resize  = 1
  g.nvim_tree_indent_markers = 1
  g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
  }
  g.nvim_tree_bindings = {
    ["l"] = ":lua require'nvim-tree'.on_keypress('edit')<CR>",
    ["s"] = ":lua require'nvim-tree'.on_keypress('vsplit')<CR>",
    ["i"] = ":lua require'nvim-tree'.on_keypress('split')<CR>",
  }
  g.nvim_tree_icons = {
    default =  '',
    -- default =  '',
    symlink = '',
    git = {
      unstaged = "✗",
      -- unstaged = "✚",
      staged = "✓",
      -- unmerged = "",
      unmerged =  "≠",
      -- renamed = "➜",
      renamed =  "≫",
      untracked = "★"
    },
  }

  -- binds
  nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
  nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
  nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

  vim.cmd[[ highlight NvimTreeFolderIcon guibg=yellow ]]
end

function config.bg()
  g.nvcode_termcolors=256
  vim.cmd [[ colo onedark ]]

  cmd('autocmd ColorScheme * highlight clear SignColumn')
  cmd('autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE')

  cmd('hi LineNr ctermbg=NONE guibg=NONE ')
  cmd('hi Comment cterm=italic')

  g.onedark_hide_endofbuffer=1
  g.onedark_terminal_italics=1
  g.onedark_termcolors=256
end

function config.bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      close_icon = ' ',
      buffer_close_icon = '',
      -- modified_icon = "",
      modified_icon = '✥',
      tab_size = 0,
      left_trunc_marker = '',
      right_trunc_marker = '',
      max_name_length = 18,
      max_prefix_length = 15,
      enforce_regular_tabs = false,
      diagnostics =  "nvim_lsp",
      separator_style = { ' ', ' ' },
      --[[ diagnostics_indicator = function(count, level)
      return ''
      end, ]]
      filter = function(buf_num)
        if not vim.t.is_help_tab then return nil end
        return vim.api.nvim_buf_get_option(buf_num, "buftype") == "help"
      end
    }
  }
end

function config.hijackc()
  cmd("highlight! LSPCurlyUnderline gui=undercurl")
  cmd("highlight! LSPUnderline gui=underline")
  cmd("highlight! LspDiagnosticsUnderlineHint gui=undercurl")
  cmd("highlight! LspDiagnosticsUnderlineInformation gui=undercurl")
  cmd("highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow")
  cmd("highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red")
  cmd("highlight! LspDiagnosticsSignHint guifg=yellow")
  cmd("highlight! LspDiagnosticsSignInformation guifg=lightblue")
  cmd("highlight! LspDiagnosticsSignWarning guifg=darkyellow")
  cmd("highlight! LspDiagnosticsSignError guifg=red")
end

return config
