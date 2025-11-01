local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local virtual_lines_variant = ar_config.lsp.virtual_lines.variant

return {
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    -- 'ErichDonGubler/lsp_lines.nvim',
    cond = function()
      local condition = ar.lsp.enable and virtual_lines_variant == 'lsp_lines'
      return ar.get_plugin_cond('lsp_lines.nvim', condition)
    end,
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    cond = not ar_config.lsp.virtual_text.enable
      and ar.lsp.enable
      and virtual_lines_variant == 'tiny-inline',
    event = 'LspAttach',
    priority = 1000,
    opts = {
      preset = 'modern', -- Can be: "modern", "classic", "minimal", "powerline", ghost", "simple", "nonerdfont", "amongus"
      transparent_bg = ar_config.ui.transparent.enable,
      options = {
        break_line = {
          enabled = true,
          after = 30,
        },
      },
    },
  },
  {
    desc = 'LSP diagnostics in virtual text at the top right of your screen',
    'dgagn/diagflow.nvim',
    cond = ar.lsp.enable and not minimal and niceties,
    event = 'LspAttach',
    opts = {
      format = function(diagnostic)
        local disabled = { 'lazy' }
        for _, v in ipairs(disabled) do
          if vim.bo.ft == v then return '' end
        end
        return diagnostic.message
      end,
      padding_top = 0,
      toggle_event = { 'InsertEnter' },
    },
  },
  {
    'folke/trouble.nvim',
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>x', group = 'Trouble' })
      ar.add_to_select_menu('command_palette', {
        ['Trouble Diagnostics'] = 'TroubleToggle',
      })
    end,
    cond = ar.lsp.enable,
    cmd = { 'Trouble' },
    -- stylua: ignore
    keys = {
      { '<localleader>xd', '<Cmd>Trouble diagnostics toggle<CR>', desc = 'trouble: toggle diagnostics' },
      {
        '<localleader>xl',
        "<Cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = 'trouble: lsp references',
      },
      { '<localleader>xL', '<Cmd>Trouble loclist toggle<CR>', desc = 'trouble: toggle loclist' },
      { '<localleader>xq', '<Cmd>Trouble qflist toggle<CR>', desc  = 'trouble: toggle qflist' },
      { '<localleader>xt', '<Cmd>Trouble todo toggle<CR>', desc = 'trouble: toggle todo' },
      { '<localleader>xx', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'trouble: toggle buffer diagnostics' },
    },
    opts = {},
  },
  {
    -- 'artemave/workspace-diagnostics.nvim',
    'razak17/workspace-diagnostics.nvim',
    cond = function()
      return ar.get_plugin_cond('workspace-diagnostics.nvim', ar.lsp.enable)
    end,
    opts = {},
  },
}
