local separators = ar.ui.icons.separators
local minimal = ar.plugins.minimal

return {
  {
    'echasnovski/mini.extra',
    cond = function() return ar.get_plugin_cond('mini.extra') end,
    config = function() require('mini.extra').setup() end,
  },
  {
    'echasnovski/mini.hipatterns',
    cond = function() return ar.get_plugin_cond('mini.hipatterns') end,
  },
  {
    'echasnovski/mini.indentscope',
    cond = function()
      local indentline_enable = ar_config.ui.indentline.enable
      local indentline_variant = ar_config.ui.indentline.variant
      return not minimal
        and indentline_enable
        and indentline_variant == 'mini.indentscope'
    end,
    event = 'UIEnter',
    opts = {
      symbol = separators.left_thin_block,
      draw = {
        delay = 100,
        priority = 2,
        animation = function(s, n) return s / n * 20 end,
      },
      -- stylua: ignore
      filetype_exclude = {
        'lazy', 'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit',
        'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline', 'undotree',
        'markdown', 'norg', 'org', 'orgagenda', 'snacks_dashboard',
        '', -- for all buffers without a file type
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('mini-indentscope', {
        theme = {
          ['onedark'] = {
            { MiniIndentscopeSymbol = { link = 'IndentBlanklineContextChar' } },
            { MiniIndentscopeSymbolOff = { link = 'IndentBlanklineChar' } },
          },
          ['default'] = {
            { MiniIndentscopeSymbol = { link = 'NonText' } },
            { MiniIndentscopeSymbolOff = { link = 'NonText' } },
          },
        },
      })
      require('mini.indentscope').setup(opts)
    end,
  },
  {
    'echasnovski/mini.bracketed',
    cond = function() return ar.get_plugin_cond('mini.bracketed', not minimal) end,
    event = { 'BufRead', 'BufNewFile' },
    opts = { buffer = { suffix = '' } },
  },
  {
    'echasnovski/mini.trailspace',
    cond = function() return ar.get_plugin_cond('mini.trailspace', not minimal) end,
    init = function()
      local trailspace = require('mini.trailspace')
      ar.add_to_select_menu('command_palette', {
        ['Remove Trailing Empty Lines'] = trailspace.trim_last_lines,
        ['Remove Trailing Spaces'] = trailspace.trim,
      })
    end,
    opts = {},
  },
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/coding/mini-surround.lua#L9
      local opts = ar.opts('mini.surround')
      local mappings = {
        { opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete Surrounding' },
        { opts.mappings.find, desc = 'Find Right Surrounding' },
        { opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { opts.mappings.replace, desc = 'Replace Surrounding' },
        {
          opts.mappings.update_n_lines,
          desc = 'Update `MiniSurround.config.n_lines`',
        },
      }
      mappings = vim.tbl_filter(
        function(m) return m[1] and #m[1] > 0 end,
        mappings
      )
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
    init = function()
      -- https://www.reddit.com/r/neovim/comments/1fddxak/can_figure_out_how_to_turn_a_large_motion_into/
      ar.command('AddSurroundingTag', function()
        vim.cmd('normal vat')
        vim.schedule(function() vim.cmd('normal gsat') end)
      end, { desc = 'add surround HTML tag' })

      ar.add_to_select_menu(
        'command_palette',
        { ['Add surround HTML tag'] = 'AddSurroundingTag' }
      )
    end,
  },
  {
    'echasnovski/mini.completion',
    cond = function()
      local condition = minimal
        or ar_config.completion.variant == 'mini.completion'
      return ar.get_plugin_cond('mini.completion', condition)
    end,
    event = { 'InsertEnter', 'BufEnter' },
    opts = {},
    config = function(_, opts)
      require('mini.completion').setup(opts)

      ar.augroup('MiniCompletionDisable', {
        event = { 'FileType' },
        desc = 'Disable completion for certain files',
        command = function()
          local ignored_filetypes = {
            'TelescopePrompt',
            'minifiles',
            'snacks_picker_input',
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.minicompletion_disable = true
          end
        end,
      })
    end,
  },
  {
    'echasnovski/mini.splitjoin',
    keys = { { '<leader>J', desc = 'splitjoin: toggle' } },
    opts = { mappings = { toggle = '<leader>J' } },
  },
  {
    'echasnovski/mini.pairs',
    cond = function() return ar.get_plugin_cond('mini.pairs', minimal) end,
    event = 'VeryLazy',
    init = function()
      local function toggle_minipairs()
        if not ar.plugin_available('mini.pairs') then return end
        vim.g.minipairs_disable = not vim.g.minipairs_disable
        if vim.g.minipairs_disable then
          vim.notify('Disabled auto pairs', 'warn', { title = 'Option' })
        else
          vim.notify('Enabled auto pairs', 'info', { title = 'Option' })
        end
      end

      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Minipairs'] = toggle_minipairs }
      )
    end,
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
      mappings = {
        ['`'] = {
          action = 'closeopen',
          pair = '``',
          neigh_pattern = '[^\\`].',
          register = { cr = false },
        },
      },
    },
  },
  {
    'echasnovski/mini.comment',
    cond = function() return ar.get_plugin_cond('mini.comment') end,
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          if ar.is_available('nvim-ts-context-commentstring') then
            return require('ts_context_commentstring.internal').calculate_commentstring()
          end
          return vim.bo.commentstring
        end,
      },
    },
  },
}
