local utils = require('user.utils.plugins')
local conf = utils.load_conf
local package = require('user.core.plugins').package

package({
  'razak17/zephyr-nvim',
  requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  local_path = 'personal',
})

package({ 'fladson/vim-kitty' })

package({ 'MunifTanjim/nui.nvim' })

package({ 'mtdl9/vim-log-highlighting' })

package({ 'kyazdani42/nvim-web-devicons' })

package({ 'goolord/alpha-nvim', config = conf('ui', 'alpha') })

package({ 'rcarriga/nvim-notify', config = conf('ui', 'notify') })

package({ 'nvim-lualine/lualine.nvim', config = conf('ui', 'lualine') })

package({ 'j-hui/fidget.nvim', config = function() require('fidget').setup() end })

package({ 'lukas-reineke/indent-blankline.nvim', config = conf('ui', 'indentline') })

package({ 'nvim-neo-tree/neo-tree.nvim', branch = 'v2.x', config = conf('ui', 'neo-tree') })

package({ 'lewis6991/gitsigns.nvim', event = 'CursorHold', config = conf('ui', 'gitsigns') })

package({ 'stevearc/dressing.nvim', after = 'telescope.nvim', config = conf('ui', 'dressing') })

package({
  'lukas-reineke/headlines.nvim',
  event = 'BufWinEnter',
  ft = { 'org', 'norg', 'markdown', 'yaml' },
  setup = function()
    if not rvim.plugin_installed('headlines.nvim') then return end
    -- https://observablehq.com/@d3/color-schemes?collection=@d3/d3-scale-chromatic
    -- NOTE: this must be set in the setup function or it will crash nvim...
    require('zephyr.utils').plugin('Headlines', {
      Headline1 = { background = '#003c30', foreground = 'White' },
      Headline2 = { background = '#00441b', foreground = 'White' },
      Headline3 = { background = '#084081', foreground = 'White' },
      Dash = { background = '#0b60a1', bold = true },
    })
  end,
  config = function()
    if not rvim.plugin_installed('headlines.nvim') then return end
    require('headlines').setup({
      markdown = {
        headline_highlights = { 'Headline1', 'Headline2', 'Headline3' },
      },
      org = {
        headline_highlights = false,
      },
      norg = { codeblock_highlight = false },
    })
  end,
})

package({
  's1n7ax/nvim-window-picker',
  tag = 'v1.*',
  config = function()
    if not rvim.plugin_installed('nvim') then return end
    require('window-picker').setup({
      autoselect_one = true,
      include_current = false,
      filter_rules = {
        bo = {
          filetype = { 'neo-tree-popup', 'quickfix', 'incline' },
          buftype = { 'terminal', 'quickfix', 'nofile' },
        },
      },
      other_win_hl_color = require('zephyr.utils').get('Visual', 'bg'),
    })
  end,
})

package({
  'itchyny/vim-highlighturl',
  config = function()
    if not rvim.plugin_installed('vim-highlighturl') then return end
    vim.g.highlighturl_guifg = require('zephyr.utils').get('URL', 'fg')
  end,
})

package({
  'kevinhwang91/nvim-ufo',
  requires = 'kevinhwang91/promise-async',
  config = conf('ui', 'ufo'),
})

package({
  'RRethy/vim-illuminate',
  config = function()
    if not rvim.plugin_installed('vim-illuminate') then return end
    vim.g.Illuminate_ftblacklist = {
      'alpha',
      'NvimTree',
      'dashboard',
      'neo-tree',
      'qf',
      'lspinfo',
      'lsp-installer',
      'harpoon',
      'packer',
      'mason.nvim',
      'help',
    }
    rvim.nnoremap('<a-n>', ':lua require"illuminate".next_reference{wrap=true}<cr>')
    rvim.nnoremap('<a-p>', ':lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')
  end,
})

package({
  'ghillb/cybu.nvim',
  event = 'BufRead',
  config = function()
    if not rvim.plugin_installed('cybu.nvim') then return end
    require('cybu').setup({
      position = {
        relative_to = 'win',
        anchor = 'topright',
      },
      style = { border = 'single', hide_buffer_id = true },
    })
    rvim.nnoremap('H', '<Plug>(CybuPrev)')
    rvim.nnoremap('L', '<Plug>(CybuNext)')
  end,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
package({
  'zbirenbaum/neodim',
  config = function()
    if not rvim.plugin_installed('neodim') then return end
    require('neodim').setup({
      blend_color = require('zephyr.utils').get('Normal', 'bg'),
      alpha = 0.60,
      hide = {
        virtual_text = false,
        signs = false,
        underline = false,
      },
    })
  end,
  disable = true,
})

package({
  'm-demare/hlargs.nvim',
  config = function()
    if not rvim.plugin_installed('hlargs.nvim') then return end
    require('zephyr.utils').plugin('hlargs', {
      Hlargs = { italic = true, bold = false, foreground = '#A5D6FF' },
    })
    require('hlargs').setup({
      excluded_argnames = {
        declarations = { 'use', 'use_rocks', '_' },
        usages = {
          go = { '_' },
          lua = { 'self', 'use', 'use_rocks', '_' },
        },
      },
    })
  end,
  disable = true,
})

package({
  'rainbowhxch/beacon.nvim',
  config = function()
    if not rvim.plugin_installed('beacon.nvim') then return end
    local beacon = require('beacon')
    beacon.setup({
      minimal_jump = 20,
      ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
      ignore_filetypes = {
        'neo-tree',
        'qf',
        'NeogitCommitMessage',
        'NeogitPopup',
        'NeogitStatus',
        'packer',
        'trouble',
      },
    })
    rvim.augroup('BeaconCmds', {
      {
        event = { 'BufReadPre' },
        pattern = { '*.norg' },
        command = function() beacon.beacon_off() end,
      },
    })
  end,
  disable = true,
})
