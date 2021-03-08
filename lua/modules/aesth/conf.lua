local config = {}

function config.bg()
  vim.g.nvcode_termcolors=256
  vim.cmd [[ colo onedark ]]

  vim.g.onedark_hide_endofbuffer=1
  vim.g.onedark_terminal_italics=1
  vim.g.onedark_termcolors=256
end

function config.galaxyline()
  require('modules.aesth.statusline.eviline')
end

function config.nvim_bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      close_icon = ' ',
      buffer_close_icon = '',
      modified_icon = "",
      -- modified_icon = '✥',
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

function config.dashboard()
  local home = os.getenv('HOME')
  vim.g.dashboard_preview_command = 'cat'
  vim.g.dashboard_preview_pipeline = 'lolcat'
  vim.g.dashboard_preview_file = home .. '/.config/nvim/static/pokemon.txt'
  vim.g.dashboard_preview_file_height = 14
  vim.g.dashboard_preview_file_width = 80
  vim.g.dashboard_default_executive = 'telescope'
  vim.g.dashboard_custom_section = {
    last_session = {
      description = {'  Recently laset session                  SPC s l'},
      command =  'SessionLoad'},
    find_history = {
      description = {'  Recently opened files                   SPC f h'},
      command =  'DashboardFindHistory'},
    find_file  = {
      description = {'  Find  File                              SPC f f'},
      command = 'DashboardFindFile'},
    new_file = {
      description = {'  New   File                              SPC t f'},
      command =  'DashboardNewFile'},
    find_word = {
      description = {'  Find  word                              SPC f w'},
      command = 'DashboardFindWord'},
    --[[ find_dotfiles = {
      description = {'  Open Personal dotfiles                  SPC f d'},
      command = 'Telescope dotfiles path=' .. home ..'/.dotfiles'},
    go_source = {
      description = {'  Find Go Source Code                     SPC f s'},
      command = 'Telescope gosource'}, ]]
  }
end

function config.nvim_tree()
  vim.g.nvim_tree_side = 'right'
  vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
  vim.g.nvim_tree_quit_on_open = 0
  vim.g.nvim_tree_hide_dotfiles = 0
  vim.g.nvim_tree_follow = 1
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_root_folder_modifier = ':~'
  vim.g.nvim_tree_tab_open = 1
  vim.g.nvim_tree_width_allow_resize  = 1
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1,
  }
  vim.g.nvim_tree_bindings = {
    ["l"] = ":lua require'nvim-tree'.on_keypress('edit')<CR>",
    ["s"] = ":lua require'nvim-tree'.on_keypress('vsplit')<CR>",
    ["i"] = ":lua require'nvim-tree'.on_keypress('split')<CR>",
  }
  vim.g.nvim_tree_icons = {
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

  vim.cmd[[ highlight NvimTreeFolderIcon guibg=NONE ]]
end

function config.illuminate()
  vim.g.Illuminate_ftblacklist = { 'javascript', 'typescript', 'jsx', 'tsx', 'html' }
end

function config.cool()
  vim.g.CoolTotalMatches = 1
end

function config.hijackc()
  vim.cmd('autocmd ColorScheme * highlight clear SignColumn')
  vim.cmd('autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE')

  vim.cmd('hi LineNr ctermbg=NONE guibg=NONE ')
  vim.cmd('hi Comment cterm=italic')

  vim.cmd("highlight! LSPCurlyUnderline gui=undercurl")
  vim.cmd("highlight! LSPUnderline gui=underline")
  vim.cmd("highlight! LspDiagnosticsUnderlineHint gui=undercurl")
  vim.cmd("highlight! LspDiagnosticsUnderlineInformation gui=undercurl")
  vim.cmd("highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow")
  vim.cmd("highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red")
  vim.cmd("highlight! LspDiagnosticsSignHint guifg=yellow")
  vim.cmd("highlight! LspDiagnosticsSignInformation guifg=lightblue")
  vim.cmd("highlight! LspDiagnosticsSignWarning guifg=darkyellow")
  vim.cmd("highlight! LspDiagnosticsSignError guifg=red")
end

function config.ColorMyPencils()
  vim.o['background']='dark'
  -- vim.cmd('highlight ColorColumn ctermbg=0 guibg=cyan')
  vim.cmd('highlight Normal guibg=none')
  vim.cmd('highlight LineNr guifg=#4dd2dc')
  vim.cmd('highlight netrwDir guifg=#aeacec')
  vim.cmd('highlight qfFileName guifg=#aed75f')
  vim.cmd('hi TelescopeBorder guifg=#4dd2dc')
  vim.cmd('hi FloatermBorder guifg=#4dd2dc')
  vim.cmd("hi TsVirtText guifg=#4dd2dc")
end

return config

