---@diagnostic disable: redundant-parameter

local codicons = ar.ui.codicons

return {
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    dependencies = {
      {
        'hrsh7th/cmp-path',
        cond = function() return ar.get_plugin_cond('cmp-path') end,
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'path',
                  priority = 5,
                  group_index = 1,
                  max_item_count = 3,
                },
                menu = { path = '[PATH]' },
              })
            end,
          },
        },
      },
      {
        'https://codeberg.org/FelipeLema/cmp-async-path',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'async_path',
                  priority = 5,
                  group_index = 1,
                  max_item_count = 3,
                },
                menu = { async_path = '[APATH]' },
              })
            end,
          },
        },
      },
      {
        'lukas-reineke/cmp-rg',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'rg',
                  priority = 4,
                  keyword_length = ar.lsp.enable and 8 or 4,
                  option = { additional_arguments = '--max-depth 8' },
                  group_index = 1,
                },
                menu = { rg = '[RG]' },
              })
            end,
          },
        },
      },
      {
        'hrsh7th/cmp-buffer',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'buffer',
                  priority = 4,
                  options = {
                    get_bufnrs = function() return vim.api.nvim_list_bufs() end,
                  },
                  group_index = 1,
                  max_item_count = 3,
                },
                menu = { buffer = '[BUF]' },
              })
            end,
          },
        },
      },
      {
        'amarakon/nvim-cmp-buffer-lines',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'buffer-lines',
                  priority = 4,
                  group_index = 1,
                  max_item_count = 3,
                },
                menu = { ['buffer-lines'] = '[BUFL]' },
              })
            end,
          },
        },
      },
      {
        'dmitmel/cmp-cmdline-history',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                menu = { cmdline_history = '[CHIST]' },
              })
            end,
          },
        },
      },
      {
        'hrsh7th/cmp-nvim-lsp-document-symbol',
        cond = ar.lsp.enable,
      },
      {
        'hrsh7th/cmp-cmdline',
        config = function() vim.o.wildmode = '' end,
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                menu = { cmdline = '[CMD]' },
              })

              local cmp = require('cmp')

              cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                  sources = cmp.config.sources(
                    { { name = 'nvim_lsp_document_symbol' } },
                    {
                      {
                        name = 'buffer',
                        option = { keyword_pattern = [[\k\+]] },
                      },
                    },
                    { { name = 'buffer-lines' } }
                  ),
                },
              })

              cmp.setup.cmdline(':', {
                sources = cmp.config.sources({
                  {
                    name = 'cmdline',
                    keyword_pattern = [=[[^[:blank:]\!]*]=],
                    max_item_count = 3,
                  },
                  {
                    name = 'async_path',
                    max_item_count = 5,
                  },
                  {
                    name = 'cmdline_history',
                    priority = 10,
                    max_item_count = 3,
                  },
                }),
              })
            end,
          },
        },
      },
      {
        'f3fora/cmp-spell',
        ft = { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' },
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'spell',
                  max_item_count = 10,
                  group_index = 2,
                },
                menu = { spell = '[SPELL]' },
              })
            end,
          },
        },
      },
      {
        'andersevenrud/cmp-tmux',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'tmux',
                  priority = 4,
                  group_index = 1,
                  max_item_count = 5,
                  option = {
                    -- Source from all panes in session instead of adjacent panes
                    all_panes = true,
                    -- Completion popup label
                    label = '[TMUX]',

                    -- Trigger character
                    trigger_characters = { '.' },

                    -- Specify trigger characters for filetype(s)
                    -- { filetype = { '.' } }
                    trigger_characters_ft = {},

                    -- Keyword patch mattern
                    keyword_pattern = [[\w\+]],

                    -- Capture full pane history
                    -- `false`: show completion suggestion from text in the visible pane (default)
                    -- `true`: show completion suggestion from text starting from the beginning of the pane history.
                    --         This works by passing `-S -` flag to `tmux capture-pane` command. See `man tmux` for details.
                    capture_history = true,
                  },
                },
                menu = { tmux = '[TMUX]' },
              })
            end,
          },
        },
      },
      {
        'SergioRibera/cmp-dotenv',
        cond = function() return ar.get_plugin_cond('cmp-dotenv') end,
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'dotenv',
                  group_index = 4,
                  max_item_count = 5,
                },
                menu = { dotenv = '[DOTENV]' },
              })
            end,
          },
        },
      },
      {
        'Gelio/cmp-natdat',
        opts = {},
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'natdat',
                  priority = 3,
                  keyword_length = 3,
                  group_index = 1,
                },
                menu = { natdat = '[NATDAT]' },
                format = {
                  natdat = {
                    icon = codicons.misc.calendar,
                    hl = 'CmpItemKindDynamic',
                  },
                },
              })
            end,
          },
        },
      },
      {
        'hrsh7th/cmp-emoji',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'emoji',
                  priority = 3,
                  group_index = 1,
                  max_item_count = 5,
                },
                menu = { emoji = '[EMOJI]' },
                format = {
                  emoji = {
                    icon = codicons.misc.smiley,
                    hl = 'CmpItemKindEmoji',
                  },
                },
              })
            end,
          },
        },
      },
      {
        'fazibear/cmp-nerdfonts',
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, {
                source = {
                  name = 'nerdfonts',
                  group_index = 3,
                  max_item_count = 5,
                },
                menu = { nerdfonts = '[NF]' },
                format = {
                  nerdfonts = {
                    icon = codicons.misc.nerd_font,
                    hl = 'CmpItemKindNerdFont',
                  },
                },
              })
            end,
          },
        },
      },
      {
        'uga-rosa/cmp-dictionary',
        cond = function()
          local condition = ar.plugins.overrides.dict.enable
          return ar.get_plugin_cond('cmp-dictionary', condition)
        end,
        config = function()
          local en_dict =
            join_paths(vim.fn.stdpath('data'), 'site', 'spell', 'en.dict')
          require('cmp_dictionary').setup({ paths = { en_dict } })
        end,
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            opts = function(_, opts)
              vim.g.cmp_add_source(opts, { menu = { dictionary = '[DICT]' } })
            end,
          },
        },
      },
    },
  },
}
