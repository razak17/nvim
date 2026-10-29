local enabled = not ar.plugins.minimal and ar.lsp.enable
local virtual_lines_variant = ar.config.lsp.virtual_lines.variant

ar.pack.add({
  {
    src = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    -- 'ErichDonGubler/lsp_lines.nvim',
    cond = function()
      local condition = enabled and virtual_lines_variant == 'lsp_lines'
      return ar.get_plugin_cond('lsp_lines.nvim', condition)
    end,
    event = 'LspAttach',
    setup = function() require('lsp_lines').setup() end,
  },
  {
    src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
    cond = function()
      local condition = not ar.config.lsp.virtual_text.enable
        and enabled
        and virtual_lines_variant == 'tiny-inline'
      return ar.get_plugin_cond('tiny-inline-diagnostic.nvim', condition)
    end,
    event = 'LspAttach',
    setup = function()
      require('tiny-inline-diagnostic').setup({
        preset = 'modern', -- Can be: "modern", "classic", "minimal", "powerline", ghost", "simple", "nonerdfont", "amongus"
        transparent_bg = ar.config.ui.transparent.enable,
        options = {
          break_line = {
            enabled = true,
            after = 30,
          },
        },
      })
    end,
  },
  {
    -- LSP diagnostics in virtual text at the top right of your screen
    src = 'https://github.com/dgagn/diagflow.nvim',
    cond = function()
      local condition = enabled and ar.plugins.niceties
      return ar.get_plugin_cond('diagflow.nvim', condition)
    end,
    event = 'LspAttach',
    setup = function()
      require('diagflow').setup({
        format = function(diagnostic)
          local disabled = { 'lazy' }
          for _, v in ipairs(disabled) do
            if vim.bo.ft == v then return '' end
          end
          return diagnostic.message
        end,
        padding_top = 0,
        toggle_event = { 'InsertEnter' },
      })
    end,
  },
  {
    src = 'https://github.com/folke/trouble.nvim',
    init = function()
      vim.g.whichkey_add_spec({ '<localleader>x', group = 'Trouble' })
      ar.add_to_select('command_palette', {
        ['Trouble Diagnostics'] = 'TroubleToggle',
      })
    end,
    cond = function() return ar.get_plugin_cond('trouble.nvim', ar.lsp.enable) end,
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
    setup = function() require('trouble').setup() end,
  },
  {
    src = 'https://github.com/artemave/workspace-diagnostics.nvim',
    lazy = false,
    cond = function()
      return ar.get_plugin_cond('workspace-diagnostics.nvim', enabled)
    end,
    setup = function() require('workspace-diagnostics').setup() end,
  },
})
