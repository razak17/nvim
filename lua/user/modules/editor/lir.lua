local M = {
  'tamago324/lir.nvim',
  event = 'VeryLazy',
}

function M.config()
  local actions = require('lir.actions')
  local mark_actions = require('lir.mark.actions')
  local clipboard_actions = require('lir.clipboard.actions')

  require('lir').setup({
    devicons = {
      enable = true,
      highlight_dirname = true,
    },
    mappings = {
      ['l'] = actions.edit,
      ['<CR>'] = actions.edit,
      ['<C-s>'] = actions.split,
      ['v'] = actions.vsplit,
      ['<C-t>'] = actions.tabedit,

      ['h'] = actions.up,
      ['q'] = actions.quit,

      ['A'] = actions.mkdir,
      ['a'] = actions.newfile,
      ['r'] = actions.rename,
      ['@'] = actions.cd,
      ['Y'] = actions.yank_path,
      ['H'] = actions.toggle_show_hidden,
      ['d'] = actions.delete,

      ['J'] = function()
        mark_actions.toggle_mark()
        vim.cmd('normal! j')
      end,
      ['c'] = clipboard_actions.copy,
      ['x'] = clipboard_actions.cut,
      ['p'] = clipboard_actions.paste,
    },
    float = {
      winblend = 0,
      curdir_window = {
        enable = false,
        highlight_dirname = true,
      },
      win_opts = function()
        return {
          border = rvim.ui.current.border,
          width = math.floor(vim.o.columns * 0.7),
          height = math.floor(vim.o.lines * 0.7),
        }
      end,
    },
    hide_cursor = false,
  })
  rvim.nnoremap('<localleader>lf', function() require('lir.float').toggle() end, 'lir: toggle')
end

return M
