local utils = require('user.utils.plugins')
local conf = utils.load_conf

local editor = {}

-- nvim-cmp
editor['hrsh7th/nvim-cmp'] = {
  module = 'cmp',
  event = 'InsertEnter',
  config = conf('lang', 'cmp'),
  requires = {
    { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
    { 'f3fora/cmp-spell', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
    { 'dmitmel/cmp-cmdline-history', after = 'nvim-cmp' },
    {
      'petertriho/cmp-git',
      after = 'nvim-cmp',
      config = function()
        require('cmp_git').setup({
          filetypes = { 'gitcommit', 'NeogitCommitMessage' },
        })
      end,
    },
    {
      'uga-rosa/cmp-dictionary',
      after = 'nvim-cmp',
      config = function()
        -- Refer to install script
        local dicwords = join_paths(rvim.get_runtime_dir(), 'site', 'dictionary.txt')
        if vim.fn.filereadable(dicwords) ~= 1 then dicwords = '/usr/share/dict/words' end
        require('cmp_dictionary').setup({
          async = true,
          dic = {
            ['*'] = dicwords,
          },
        })
        require('cmp_dictionary').update()
      end,
    },
  },
}

editor['L3MON4D3/LuaSnip'] = {
  event = 'InsertEnter',
  module = 'luasnip',
  requires = 'rafamadriz/friendly-snippets',
  config = conf('lang', 'luasnip'),
}

editor['xiyaowong/accelerated-jk.nvim'] = {
  event = { 'BufWinEnter' },
  config = function()
    require('accelerated-jk').setup({
      mappings = { j = 'gj', k = 'gk' },
      -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
      -- acceleration_limit = 150,
    })
  end,
}

editor['kylechui/nvim-surround'] = {
  config = function() require('nvim-surround').setup({}) end,
}

editor['monaqa/dial.nvim'] = {
  event = { 'BufWinEnter' },
  config = conf('editor', 'dial'),
}

editor['norcalli/nvim-colorizer.lua'] = {
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('colorizer').setup({ 'lua', 'css', 'vim', 'kitty', 'conf' }, {
      css = { rgb_fn = true, hsl_fn = true, names = true },
      scss = { rgb_fn = true, hsl_fn = true, names = true },
      sass = { rgb_fn = true, names = true },
      vim = { names = true },
      html = { mode = 'foreground' },
    }, {
      RGB = false,
      names = false,
      mode = 'background',
    })
  end,
}

editor['romainl/vim-cool'] = {
  event = { 'BufWinEnter' },
  config = function() vim.g.CoolTotalMatches = 1 end,
}

editor['jghauser/fold-cycle.nvim'] = {
  config = function()
    require('fold-cycle').setup()
    rvim.nnoremap('<BS>', function() require('fold-cycle').open() end)
  end,
}

editor['numToStr/Comment.nvim'] = {
  config = function()
    require('Comment').setup()
    local ft = require('Comment.ft')
    ft
      .set('javascriptreact',  '{/*%s*/}')
      .set('javascript.jsx',   '{/*%s*/}')
      .set('typescriptreact',   '{/*%s*/}')
      .set('typescript.tsx',   '{/*%s*/}')
      .set('graphql', '//%s')
      .set('json', '//%s')
  end,
}

editor['Matt-A-Bennett/vim-surround-funk'] = {
  event = 'BufWinEnter',
  config = function()
    vim.g.surround_funk_create_mappings = 0
    local map = vim.keymap.set
    -- operator pending mode: grip surround
    map({ 'n', 'v' }, 'gs', '<Plug>(GripSurroundObject)')
    map({ 'o', 'x' }, 'sF', '<Plug>(SelectWholeFUNCTION)')

    require('which-key').register({
      ['<leader>rf'] = { '<Plug>(DeleteSurroundingFunction)', 'dsf: delete surrounding function' },
      ['<leader>rF'] = {
        '<Plug>(DeleteSurroundingFUNCTION)',
        'dsf: delete surrounding outer function',
      },
      ['<leader>Cf'] = { '<Plug>(ChangeSurroundingFunction)', 'dsf: change surrounding function' },
      ['<leader>CF'] = {
        '<Plug>(ChangeSurroundingFUNCTION)',
        'dsf: change outer surrounding function',
      },
    })
  end,
}

editor['danymat/neogen'] = {
  event = { 'BufWinEnter' },
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    local neogen = require('neogen')
    require('neogen').setup({ snippet_engine = 'luasnip' })
    rvim.nnoremap('<localleader>lc', function() neogen.generate() end, 'git: commit dotfiles')
  end,
}

editor['chentoast/marks.nvim'] = {
  event = { 'BufWinEnter' },
  config = function()
    require('zephyr.utils').plugin(
      'marks',
      { MarkSignHL = { link = 'Directory' }, MarkSignNumHL = { link = 'Directory' } }
    )
    require('which-key').register({
      m = {
        name = 'Marks',
        b = { '<Cmd>MarksListBuf<CR>', 'list buffer' },
        g = { '<Cmd>MarksQFListGlobal<CR>', 'list global' },
        ['0'] = { '<Cmd>BookmarksQFList 0<CR>', 'list bookmark' },
      },
    }, {
      prefix = '<leader>',
    })
    require('marks').setup({
      force_write_shada = false, -- This can cause data loss
      excluded_filetypes = { 'NeogitStatus', 'NeogitCommitMessage', 'toggleterm' },
      bookmark_0 = {
        sign = '⚑',
        virt_text = '',
      },
      mappings = {
        annotate = 'm?',
      },
    })
  end,
}

editor['psliwka/vim-dirtytalk'] = {
  run = ':DirtytalkUpdate',
}

editor['jsborjesson/vim-uppercase-sql'] = {
  event = 'InsertEnter',
  ft = { 'sql' },
  disable = true,
}

editor['glepnir/template.nvim'] = {
  config = function()
    local temp = require('template')
    temp.temp_dir = ('%s/templates/'):format(rvim.get_config_dir())
    -- temp.temp_dir = join_paths(rvim.get_config_dir(), 'templates')
  end,
  disable = true,
}

editor['AckslD/nvim-trevJ.lua'] = {
  module = 'trevj',
  setup = function()
    rvim.nnoremap(
      'gj',
      function() require('trevj').format_at_cursor() end,
      { desc = 'splitjoin: split' }
    )
  end,
  config = function() require('trevj').setup() end,
  disable = true,
}

editor['junegunn/vim-easy-align'] = {
  config = function()
    rvim.nmap('ga', '<Plug>(EasyAlign)')
    rvim.xmap('ga', '<Plug>(EasyAlign)')
    rvim.vmap('<Enter>', '<Plug>(EasyAlign)')
  end,
  event = { 'BufReadPre', 'BufNewFile' },
  disable = true,
}

editor['xiyaowong/nvim-cursorword'] = {
  event = { 'InsertEnter' },
  config = function() vim.cmd([[hi! CursorWord cterm=NONE gui=NONE guibg=#3f444a]]) end,
  disable = true,
}

editor['abecodes/tabout.nvim'] = {
  wants = { 'nvim-treesitter' },
  after = { 'nvim-cmp' },
  config = function() require('tabout').setup({ ignore_beginning = false, completion = false }) end,
  disable = true,
}

return editor
