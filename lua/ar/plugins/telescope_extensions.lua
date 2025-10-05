local function get_cond(plugin)
  return function()
    local condition = ar_config.picker.variant == 'telescope'
    if not plugin then return condition end
    return ar.get_plugin_cond(plugin, condition)
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    dependencies = {
      {
        'nvim-telescope/telescope-frecency.nvim',
        cond = get_cond('telescope-frecency.nvim'),
        keys = {
          {
            '<leader>fh',
            function()
              require('telescope').extensions.frecency.frecency({
                workspace = 'CWD',
              })
            end,
            desc = 'Most (f)recently used files',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            local datapath = vim.fn.stdpath('data')
            vim.g.telescope_add_extension({ 'frecency' }, opts, {
              frecency = {
                db_root = join_paths(datapath, 'databases'),
                default_workspace = 'CWD',
                show_filter_column = false,
                show_scores = true,
                show_unindexed = true,
                db_safe_mode = false,
                auto_validate = true,
                db_validate_threshold = 20,
                ignore_patterns = {
                  '*/tmp/*',
                  '*node_modules/*',
                  '*vendor/*',
                },
                workspaces = {
                  conf = vim.g.dotfiles,
                  project = vim.g.projects_dir,
                },
              },
            })
          end,
        },
      },
      {
        'jonarrien/telescope-cmdline.nvim',
        cond = function()
          local condition = ar_config.ui.cmdline.variant == 'telescope-cmdline'
          return ar.get_plugin_cond('telescope-cmdline.nvim', condition)
        end,
        keys = {
          { ':', '<Cmd>Telescope cmdline<CR>', desc = 'Cmdline' },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'cmdline' }, opts)
          end,
        },
      },
      {
        'danielfalk/smart-open.nvim',
        cond = function()
          local condition = ar_config.picker.files == 'smart-open'
          return ar.get_plugin_cond('smart-open.nvim', condition)
        end,
        keys = {
          {
            '<C-p>',
            function()
              require('telescope').extensions.smart_open.smart_open({
                cwd_only = true,
                no_ignore = true,
                show_scores = false,
              })
            end,
            desc = 'smart open',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'smart_open' }, opts, {
              ['smart_open'] = {
                show_scores = true,
                ignore_patterns = {
                  '*.git/*',
                  '*/tmp/*',
                  '*vendor/*',
                  '*node_modules/*',
                },
                match_algorithm = 'fzf',
                disable_devicons = false,
              },
            })
          end,
        },
      },
      {
        'nvim-telescope/telescope-file-browser.nvim',
        cond = get_cond('telescope-file-browser.nvim'),
        keys = function()
          local function file_browser(opts)
            opts = vim.tbl_extend('keep', opts or {}, {
              hidden = true,
              no_ignore = true,
              sort_mru = true,
              sort_lastused = true,
            })
            require('telescope').extensions.file_browser.file_browser(opts)
          end

          -- stylua: ignore
          return {
            { '<leader>f,', file_browser, desc = 'file browser (root)' },
            { '<leader>f.', function() file_browser({ path = '%:p:h', select_buffer = 'true' }) end, desc = 'file browser (curr dir)', },
          }
        end,
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'file_browser' }, opts)
          end,
        },
      },
      {
        'debugloop/telescope-undo.nvim',
        cond = function() return ar.get_plugin_cond('telescope-cmdline.nvim') end,
        keys = {
          {
            '<leader>fu',
            function() require('telescope').extensions.undo.undo() end,
            desc = 'undo',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'undo' }, opts, {
              undo = {
                mappings = {
                  i = {
                    ['<C-a>'] = require('telescope-undo.actions').yank_additions,
                    ['<C-d>'] = require('telescope-undo.actions').yank_deletions,
                    ['<C-u>'] = require('telescope-undo.actions').restore,
                  },
                },
              },
            })
          end,
        },
      },
      {
        'nvim-telescope/telescope-smart-history.nvim',
        cond = false,
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'smart_history' }, opts)
          end,
        },
      },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        cond = get_cond('telescope-live-grep-args.nvim'),
        version = '^1.0.0',
        keys = function()
          local function live_grep_args()
            require('telescope').extensions.live_grep_args.live_grep_args({
              vimgrep_arguments = {
                'rg',
                '--color=never',
                '--no-heading',
                '--with-filename',
                '--line-number',
                '--column',
                '--smart-case',
              },
            })
          end
          local function live_grep_args_word()
            local ok, lga_shortcuts =
              pcall(require, 'telescope-live-grep-args.shortcuts')
            if not ok then
              vim.notify('telescope-live-grep-args.nvim is not installed')
              return
            end
            lga_shortcuts.grep_word_under_cursor()
          end
          local function live_grep_args_selection()
            local ok, lga_shortcuts =
              pcall(require, 'telescope-live-grep-args.shortcuts')
            if not ok then
              vim.notify('telescope-live-grep-args.nvim is not installed')
              return
            end
            lga_shortcuts.grep_visual_selection()
          end

          -- stylua: ignore
          return {
            { '<leader>fga', live_grep_args, desc = 'live-grep-args: grep' },
            { '<leader>fgw', live_grep_args_word, desc = 'live-grep-args: word' },
            { '<leader>fgs', live_grep_args_selection, desc = 'live-grep-args: selection', mode = { 'x' } },
          }
        end,
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'live_grep_args' }, opts, {
              live_grep_args = {
                auto_quoting = true,
                mappings = {
                  i = {
                    ['<c-y>'] = require('telescope-live-grep-args.actions').quote_prompt(),
                    ['<c-i>'] = require('telescope-live-grep-args.actions').quote_prompt({
                      postfix = ' --iglob ',
                    }),
                    ['<C-r>'] = require('telescope-live-grep-args.actions').to_fuzzy_refine,
                  },
                },
              },
            })
          end,
        },
      },
      {
        'razak17/telescope-lazy.nvim',
        cond = get_cond('telescope-lazy.nvim'),
        keys = {
          {
            '<leader>fl',
            function() require('telescope').extensions.lazy.lazy() end,
            desc = 'surf plugins',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'lazy' }, opts, {
              lazy = {
                name = 'lazy',
                show_icon = true,
                mappings = {
                  open_in_float = '<C-o>',
                  open_in_browser = '<C-b>',
                  open_in_file_browser = '<M-b>',
                  open_in_find_files = '<C-f>',
                  open_in_live_grep = '<C-g>',
                  -- open_plugins_picker = '<C-b>',
                  open_lazy_root_find_files = '<C-r>f',
                  open_lazy_root_live_grep = '<C-r>g',
                },
              },
            })
          end,
        },
      },
      {
        'fdschmidt93/telescope-egrepify.nvim',
        cond = get_cond('telescope-egrepify.nvim'),
        keys = {
          {
            '<leader>fe',
            function() require('telescope').extensions.egrepify.egrepify() end,
            desc = 'egrepify',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'egrepify' }, opts)
          end,
        },
      },
      {
        'telescope-helpgrep.nvim',
        cond = get_cond('telescope-helpgrep.nvim'),
        keys = {
          {
            '<leader>fH',
            function() require('telescope').extensions.helpgrep.helpgrep() end,
            desc = 'egrepify',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'helpgrep' }, opts, {
              helpgrep = {
                ignore_paths = { vim.fn.stdpath('state') .. '/lazy/readme' },
              },
            })
          end,
        },
      },
      {
        'matkrin/telescope-spell-errors.nvim',
        cond = get_cond('telescope-spell-errors.nvim'),
        keys = {
          {
            '<leader>fX',
            function()
              require('telescope').extensions.spell_errors.spell_errors()
            end,
            desc = 'spell errors',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'spell_errors' }, opts)
          end,
        },
      },
      {
        'biozz/whop.nvim',
        cond = get_cond('whop.nvim'),
        keys = {
          {
            '<leader>fW',
            function()
              require('telescope').extensions.whop.whop(
                ar.telescope.minimal_ui()
              )
            end,
            desc = 'whop',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'whop' }, opts)
          end,
        },
      },
      {
        'fbuchlak/telescope-directory.nvim',
        cond = get_cond('telescope-directory.nvim'),
        opts = {},
        keys = function()
          local function directory_files()
            require('telescope').extensions.directory.directory({
              feature = 'find_files',
            })
          end
          local function directory_search()
            require('telescope').extensions.directory.directory({
              feature = 'live_grep',
              feature_opts = { hidden = true, no_ignore = true },
              hidden = true,
              no_ignore = true,
            })
          end

          -- stylua: ignore
          return {
            { '<leader>fgf', directory_files, desc = 'directory for find files' },
            { '<leader>fgg', directory_search, desc = 'directory for live grep' },
          }
        end,
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'directory' }, opts)
          end,
        },
      },
      {
        'isak102/telescope-git-file-history.nvim',
        cond = get_cond('telescope-git-file-history.nvim'),
        keys = {
          {
            '<leader>fgh',
            function()
              require('telescope').extensions.git_file_history.git_file_history()
            end,
            desc = 'git file history',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'git_file_history' }, opts)
          end,
        },
      },
      {
        'mrloop/telescope-git-branch.nvim',
        cond = get_cond('telescope-git-branch'),
        -- stylua: ignore
        keys = {
          { mode = { 'n', 'v' }, '<leader>gf', function() require('git_branch').files() end, desc = 'git branch' },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'git_branch' }, opts)
          end,
        },
      },
      {
        'Myzel394/jsonfly.nvim',
        cond = get_cond('jsonfly.nvim'),
        keys = {
          {
            '<leader>fj',
            '<Cmd>Telescope jsonfly<CR>',
            desc = 'Open json(fly)',
          },
        },
      },
      {
        'ahmedkhalf/project.nvim',
        config = function()
          require('project_nvim').setup({
            active = true,
            manual_mode = false,
            detection_methods = { 'pattern', 'lsp' },
            patterns = {
              '.git',
              '.hg',
              '.svn',
              'Makefile',
              'package.json',
              '.luacheckrc',
              '.stylua.toml',
            },
            show_hidden = false,
            silent_chdir = true,
            ignore_lsp = { 'null-ls' },
            datapath = vim.fn.stdpath('data'),
          })
        end,
        keys = {
          {
            '<leader>fp',
            function()
              require('telescope').extensions.projects.projects(
                ar.telescope.minimal_ui()
              )
            end,
            desc = 'projects',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'projects' }, opts)
          end,
        },
      },
      {
        'dapc11/telescope-yaml.nvim',
        cond = get_cond('telescope-yaml.nvim'),
        keys = {
          { '<leader>fy', '<Cmd>Telescope telescope-yaml<CR>', desc = 'yaml' },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'telescope-yaml' }, opts)
          end,
        },
      },
      {
        'crispgm/telescope-heading.nvim',
        cond = get_cond('telescope-heading.nvim'),
        keys = {
          { '<leader>fU', '<Cmd>Telescope heading<CR>', desc = 'headings' },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'heading' }, opts, {
              heading = { treesitter = true },
            })
          end,
        },
      },
      {
        'chip/telescope-software-licenses.nvim',
        cond = get_cond('telescope-software-licenses.nvim'),
        keys = {
          {
            '<leader>fL',
            function()
              require('telescope').extensions['software-licenses'].find(
                ar.telescope.horizontal()
              )
            end,
            desc = 'software licenses',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'software-licenses' }, opts)
          end,
        },
      },
    },
  },
}
