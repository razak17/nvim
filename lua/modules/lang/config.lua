local config = {}

function config.treesitter()
  require('modules.lang.ts').setup()
end

function config.nvim_lsp()
  require('modules.lang.lsp.lspconfig')
end

function config.dap()
  require 'modules.lang.dap'
end

function config.symbols()
  require("symbols-outline").setup {
    highlight_hovered_item = true,
    show_guides = true
  }
end

function config.trouble()
  require("trouble").setup {
    height = 12,
    use_lsp_diagnostic_signs = true,
    action_keys = {toggle_fold = "ze"}
  }
end

function config.dap_ui()
  require("dapui").setup({
    mappings = {expand = "<CR>", open = "o", remove = "d"},
    sidebar = {
      elements = {"scopes", "stacks", "watches"},
      width = 60,
      position = "left"
    },
    tray = {elements = {"repl"}, height = 10, position = "bottom"}
  })
end

function config.lsp_saga()
  local opts = {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    code_action_icon = '💡',
    finder_action_keys = {quit = 'x'}
  }
  return opts
end

function config.bqf()
  require('bqf').setup({
    auto_enable = true,
    preview = {win_height = 12, win_vheight = 12, delay_syntax = 80},
    func_map = {vsplit = '<C-v>', ptogglemode = 'z,', stoggleup = 'z<Tab>'},
    filter = {
      fzf = {
        action_for = {['ctrl-s'] = 'split'},
        extra_opts = {'--bind', 'ctrl-o:toggle-all', '--prompt', '> '}
      }
    }
  })
end

function config.vim_vista()
  vim.g['vista#renderer#enable_icon'] = 1
  vim.g.vista_icon_indent = [["╰─▸ "], ["├─▸ "]]
  vim.g.vista_disable_statusline = 1
  vim.g.vista_default_executive = 'ctags'
  vim.g.vista_echo_cursor_strategy = 'floating_win'
  vim.g.vista_vimwiki_executive = 'markdown'
  vim.g.vista_executive_for = {
    vimwiki = 'markdown',
    pandoc = 'markdown',
    markdown = 'toc',
    typescript = 'nvim_lsp',
    typescriptreact = 'nvim_lsp'
  }
end

return config
