local config = {}

local fts = {"lua", "javascript", "typescript", "html"}
function config.treesitter()
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require'nvim-treesitter.configs'.setup {
    ensure_installed = fts,
    highlight = {enable = true}
  }
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
