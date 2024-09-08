local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local P = require('onedark.palette')

return {
  {
    'mrjones2014/smart-splits.nvim',
    opts = {},
    build = './kitty/install-kittens.bash',
  },
  {
    'kwkarlwang/bufresize.nvim',
    cond = not minimal,
    event = { 'WinNew' },
    opts = {},
  },
  {
    'anuvyklack/windows.nvim',
    cond = not minimal,
    init = function()
      require('which-key').add({ { '<leader>wm', group = 'Maximizer' } })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>wmh', '<Cmd>WindowsMaximizeHorizontally<CR>', desc = 'maximize horizontally' },
      { '<leader>wmv', '<Cmd>WindowsMaximizeVertically<CR>', desc = 'maximize vertically' },
      { '<leader>wmm', '<Cmd>WindowsMaximize<CR>', desc = 'maximize' },
      { '<leader>wm=', '<Cmd>WindowsEqualize<CR>', desc = 'equalize' },
      { '<leader>wmt', '<Cmd>WindowsToggleAutowidth<CR>', desc = 'toggle' },
      { "<leader>wmz", function() require("neo-zoom").neo_zoom({}) end, desc = "zoom window", },
    },
    opts = {},
    config = function(_, opts)
      require('neo-zoom').setup({})
      require('windows').setup(opts)
    end,
    dependencies = { 'anuvyklack/middleclass', 'nyngwang/NeoZoom.lua' },
  },
  {
    'sindrets/winshift.nvim',
    cmd = { 'WinShift' },
    -- stylua: ignore
    keys = {
      { '<leader>sw', '<Cmd>WinShift<CR>', desc = 'winshift: start winshift mode', },
      { '<leader>ss', '<Cmd>WinShift swap<CR>', desc = 'winshift: swap two window', },
      { '<leader>sh', '<Cmd>WinShift left<CR>', desc = 'winshift: swap left' },
      { '<leader>sj', '<Cmd>WinShift down<CR>', desc = 'winshift: swap down' },
      { '<leader>sk', '<Cmd>WinShift up<CR>', desc = 'winshift: swap up' },
      { '<leader>sl', '<Cmd>WinShift right<CR>', desc = 'winshift: swap right', },
    },
    opts = {},
  },
  {
    'nvim-zh/colorful-winsep.nvim',
    cond = not minimal and niceties,
    event = { 'WinNew' },
    opts = {
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
      highlight = {
        bg = ar.ui.transparent.enable and 'NONE'
          or ar.highlight.get('Normal', 'bg'),
        fg = P.cursor,
      },
    },
  },
}
