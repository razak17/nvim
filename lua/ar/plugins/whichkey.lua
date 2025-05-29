---Set up plugin-specific groups cleanly with the plugin config.
---@param spec wk.Spec
vim.g.whichkey_add_spec = function(spec)
  if not ar.is_available('which-key.nvim') then return end
  -- Deferred to ensure spec is loaded after whichkey itself
  vim.defer_fn(function() require('which-key').add(spec) end, 1500)
end

return {
  'folke/which-key.nvim',
  cond = not ar.plugin_disabled('which-key.nvim'),
  event = 'VeryLazy',
  opts = function()
    local opts = {
      icons = {
        rules = false,
        keys = { CR = '↪', TAB = '→', Space = '󱁐 ' },
      },
      preset = 'helix',
      defaults = {},
      spec = {
        {
          mode = { 'n' },
          { '<leader>[', group = 'Replace all' },
          { '<leader>]', group = 'Replace in line' },
          { '<leader>A', group = 'Animations' },
          { '<leader>F', group = 'Picker (Current Dir)' },
          { '<leader>a', group = 'A.I.' },
          { '<leader>e', group = 'Explorer' },
          { '<leader>f', group = 'Picker' },
          { '<leader>fg', group = 'Git' },
          { '<leader>fl', group = 'Lazy' },
          { '<leader>fq', group = 'List' },
          { '<leader>fv', group = 'Vim' },
          { '<leader>g', group = 'Git' },
          { '<leader>gb', group = 'Blame' },
          { '<leader>go', group = 'Open' },
          { '<leader>gs', group = 'Stash' },
          { '<leader>gy', group = 'Yank' },
          { '<leader>h', group = 'Gitsigns' },
          { '<leader>i', group = 'Toggler/Swap' },
          { '<leader>l', group = 'LSP' },
          { '<leader>ls', group = 'Symbols' },
          { '<leader>m', group = 'Marks' },
          { '<leader>n', group = 'Notify' },
          { '<leader>o', group = 'UI select' },
          { '<leader>p', group = 'Print/Log' },
          { '<leader>q', group = 'Quit/Session' },
          { '<leader>r', group = 'Run' },
          { '<leader>s', group = 'Splits' },
          { '<leader>u', group = 'UI' },
          { '<leader>v', group = 'Vim' },
          { '<leader>w', group = 'Window' },
          { '<localleader>a', group = 'Actions' },
          { '<localleader>b', group = 'Buffer' },
          { '<localleader>c', group = 'Conceal' },
          { '<localleader>g', group = 'Git' },
          { '<localleader>go', group = 'Open' },
          { '<localleader>gy', group = 'Yank' },
          { '<localleader>h', group = 'Harpoon' },
          { '<localleader>l', group = 'LSP' },
          { '<localleader>lc', group = 'Call Hierarchy' },
          { '<localleader>lr', group = 'Rulebook' },
          { '<localleader>m', group = 'Markdown' },
          { '<localleader>n', group = 'Neogen/Notifications' },
          { '<localleader>o', group = 'Open' },
          { '<leader><leader>', group = 'Advanced' },
          { '<leader><leader>f', group = 'File' },
          { '<leader><leader>g', group = 'Git' },
          { '<leader><leader>gh', group = 'History' },
          { '<leader><leader>gi', group = 'Issues' },
          { '<leader><leader>go', group = 'Open' },
          { '<leader><leader>m', desc = 'Markdown' },
          { '<leader><leader>n', group = 'Sticky Note' },
          { '<leader><localleader>', group = 'Advanced' },
          { '<localleader><leader>', group = 'Advanced' },
        },
        {
          mode = { 'x' },
          { '<leader><leader>', group = 'Advanced' },
          { '<leader>a', group = 'Actions' },
          { '<leader>d', group = 'Delete' },
          { '<leader>f', group = 'File' },
          { '<leader>g', group = 'Git' },
          { '<leader>go', group = 'Open' },
          { '<leader>h', group = 'Hunk' },
          { '<leader>l', group = 'LSP' },
          { '<leader>r', group = 'Run' },
          { '<leader>u', group = 'UI' },
          { '<localleader>a', group = 'A.I.' },
          { '<localleader>g', group = 'Git' },
          { '<localleader>h', group = 'Gitsigns' },
          { '<localleader>l', group = 'LSP' },
          { '<localleader>p', group = 'Share' },
          { '<leader><leader>m', desc = 'Markdown' },
          { '<leader><leader>ml', desc = 'Link' },
        },
      },
    }
    if opts.preset == 'classic' then
      opts.layout = { align = 'center' }
      opts.win = {
        col = 0.5,
        height = { min = 10, max = 25 },
        border = ar.ui.current.border,
        wo = {
          winblend = ar_config.ui.transparent.enable and 0 or 12, -- value between 0-100 0 for fully opaque and 100 for fully transparent
        },
      }
    end
    return opts
  end,
  keys = {
    {
      '<leader>?',
      function() require('which-key').show({ global = false }) end,
      desc = 'which-key: buffer keymaps',
    },
    {
      '<c-w><space>',
      function() require('which-key').show({ keys = '<c-w>', loop = true }) end,
      desc = 'which-key: window hydra mode',
    },
  },
  init = function()
    ar.augroup('WhichKeyMode', {
      event = { 'FileType' },
      pattern = { 'which_key' },
      command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
    })
  end,
}
