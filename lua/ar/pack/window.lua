local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

ar.pack.add({
  {
    src = 'https://github.com/anuvyklack/windows.nvim',
    cond = function() return ar.get_plugin_cond('windows.nvim', not minimal) end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>wm', group = 'Maximizer' })
      ar.add_to_select('command_palette', {
        ['Maximize Window'] = 'lua require("windows.commands").maximize()',
      })
    end,
    keys = {
      {
        '<leader>wmh',
        '<Cmd>WindowsMaximizeHorizontally<CR>',
        desc = 'maximize horizontally',
      },
      {
        '<leader>wmv',
        '<Cmd>WindowsMaximizeVertically<CR>',
        desc = 'maximize vertically',
      },
      { '<leader>wmm', '<Cmd>WindowsMaximize<CR>', desc = 'maximize' },
      { '<leader>wm=', '<Cmd>WindowsEqualize<CR>', desc = 'equalize' },
      { '<leader>wmt', '<Cmd>WindowsToggleAutowidth<CR>', desc = 'toggle' },
      {
        '<leader>wmz',
        function() require('neo-zoom').neo_zoom({}) end,
        desc = 'zoom window',
      },
    },
    dependencies = {
      { src = 'https://github.com/anuvyklack/middleclass' },
      { src = 'https://github.com/nyngwang/NeoZoom.lua' },
    },
    setup = function()
      require('neo-zoom').setup()
      require('windows').setup()
    end,
  },
  {
    src = 'https://github.com/nvim-zh/colorful-winsep.nvim',
    cond = function()
      local condtion = not minimal and niceties
      return ar.get_plugin_cond('winshift.nvim', condtion)
    end,
    event = { 'WinNew' },
    setup = function()
      require('colorful-winsep').setup((function()
        return {
          no_exec_files = {
            'NeogitCommitMessage',
            'TelescopePrompt',
            'Trouble',
            'mason',
            'neo-tree',
            'packer',
            'DiffviewFileHistory',
            'NeogitPopup',
            'NeogitConsole',
            'noice',
            'qf',
            'fzf',
            'fugitive',
          },
          highlight = ar.highlight.tint(
            ar.highlight.get('WinSeparator', 'fg'),
            0.4
          ),
        }
      end)(nil, {}) or {})
    end,
  },
})
