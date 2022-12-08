return function()
  local previewers = require('telescope.previewers')
  local sorters = require('telescope.sorters')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local layout_actions = require('telescope.actions.layout')
  local themes = require('telescope.themes')
  local icons = rvim.style.icons
  local border = rvim.style.border
  local fmt, fn = string.format, vim.fn

  rvim.telescope = {}

  rvim.augroup('TelescopePreviews', {
    {
      event = { 'User' },
      pattern = { 'TelescopePreviewerLoaded' },
      command = 'setlocal number',
    },
  })

  -- https://github.com/nvim-telescope/telescope.nvim/issues/1048
  -- Ref: https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/telescope/init.lua
  rvim.telescope.custom_actions = {}

  -- Open multiple files at once
  function rvim.telescope.custom_actions._multiopen(prompt_bufnr, open_cmd)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = #picker:get_multi_selection()
    if not num_selections or num_selections <= 1 then actions.add_selection(prompt_bufnr) end
    actions.send_selected_to_qflist(prompt_bufnr)
    vim.cmd('cfdo ' .. open_cmd)
  end

  function rvim.telescope.custom_actions.multi_selection_open(prompt_bufnr)
    rvim.telescope.custom_actions._multiopen(prompt_bufnr, 'edit')
  end

  local function get_border(opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      borderchars = border.telescope.ui_select,
    })
  end

  ---@param opts table
  ---@return table
  function rvim.telescope.minimal_ui(opts)
    return require('telescope.themes').get_dropdown(vim.tbl_deep_extend('force', opts or {}, {
      previewer = false,
      hidden = true,
      borderchars = border.telescope.ui_select,
    }))
  end

  ---@param opts table
  ---@return table
  function rvim.telescope.dropdown(opts) return themes.get_dropdown(get_border(opts)) end

  ---@param opts table
  ---@return table
  function rvim.telescope.ivy(opts)
    return require('telescope.themes').get_ivy(vim.tbl_deep_extend('keep', opts or {}, {
      borderchars = {
        preview = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' },
      },
    }))
  end

  local telescope = require('telescope')

  local function stopinsert(callback)
    return function(prompt_bufnr)
      vim.cmd.stopinsert()
      vim.schedule(function() callback(prompt_bufnr) end)
    end
  end

  telescope.setup({
    defaults = {
      prompt_prefix = ' ' .. icons.misc.chevron_right_alt .. ' ',
      selection_caret = ' ' .. icons.misc.chevron_right_alt .. ' ', --  ,
      cycle_layout_list = { 'flex', 'horizontal', 'vertical', 'bottom_pane', 'center' },
      sorting_strategy = 'ascending',
      layout_strategy = 'horizontal',
      set_env = { ['TERM'] = vim.env.TERM },
      borderchars = border.common,
      file_browser = { hidden = true },
      color_devicons = true,
      dynamic_preview_title = true,
      layout_config = {
        height = 0.9,
        width = 0.9,
        preview_cutoff = 120,
        horizontal = {
          width_padding = 0.04,
          height_padding = 0.1,
          preview_width = 0.6,
        },
        vertical = {
          width_padding = 0.05,
          height_padding = 0.1,
          preview_height = 0.5,
        },
      },
      winblend = 0,
      history = {
        path = rvim.get_cache_dir() .. '/telescope/history.sqlite3',
      },
      file_ignore_patterns = {
        '%.jpg',
        '%.jpeg',
        '%.png',
        '%.otf',
        '%.ttf',
        '%.DS_Store',
        '%.lock',
        '.git/',
        'node_modules/',
        'dist/',
        'build/',
        'site-packages/',
      },
      path_display = { 'truncate' },
      file_sorter = sorters.get_fzy_sorter,
      file_previewer = previewers.vim_buffer_cat.new,
      grep_previewer = previewers.vim_buffer_vimgrep.new,
      qflist_previewer = previewers.vim_buffer_qflist.new,
      mappings = {
        i = {
          ['<C-w>'] = actions.send_selected_to_qflist,
          ['<c-c>'] = function() vim.cmd.stopinsert() end,
          ['<esc>'] = actions.close,
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          ['<c-s>'] = actions.select_horizontal,
          ['<c-e>'] = layout_actions.toggle_preview,
          ['<c-l>'] = layout_actions.cycle_layout_next,
          ['<C-a>'] = rvim.telescope.custom_actions.multi_selection_open,
          ['<Tab>'] = actions.toggle_selection,
          ['<CR>'] = stopinsert(actions.select_default),
        },
        n = {
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          ['<C-a>'] = rvim.telescope.custom_actions.multi_selection_open,
        },
      },
      extensions = {
        media_files = {
          -- filetypes whitelist
          -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
          filetypes = { 'png', 'webp', 'jpg', 'jpeg' },
          find_cmd = 'rg', -- find command (defaults to `fd`)
        },
        ['ui-select'] = {
          themes.get_cursor(get_border({
            layout_config = {
              cursor = {
                width = 25,
              },
            },
          })),
        },
        frecency = {
          default_workspace = 'CWD',
          show_unindexed = false, -- Show all files or only those that have been indexed
          ignore_patterns = { '*.git/*', '*/tmp/*', '*node_modules/*', '*vendor/*' },
          workspaces = {
            conf = vim.env.DOTFILES,
            project = vim.env.DEV_HOME,
          },
        },
      },
      pickers = {
        buffers = rvim.telescope.dropdown({
          sort_mru = true,
          sort_lastused = true,
          show_all_buffers = true,
          ignore_current_buffer = true,
          previewer = false,
          theme = 'dropdown',
          mappings = {
            i = { ['<c-x>'] = 'delete_buffer' },
            n = { ['<c-x>'] = 'delete_buffer' },
          },
        }),
        find_files = {
          hidden = true,
        },
        keymaps = rvim.telescope.dropdown({
          layout_config = {
            height = 18,
            width = 0.5,
          },
        }),
        live_grep = rvim.telescope.ivy({
          --@usage don't include the filename in the search results
          only_sort_text = true,
          -- NOTE: previewing html seems to cause some stalling/blocking whilst live grepping
          -- so filter out html.
          file_ignore_patterns = {
            '.git/',
            '%.html',
            'dotbot/.*',
            'zsh/plugins/.*',
          },
          max_results = 2000,
        }),
        registers = rvim.telescope.dropdown({
          layout_config = {
            height = 25,
          },
        }),
        oldfiles = rvim.telescope.dropdown(),
        current_buffer_fuzzy_find = rvim.telescope.dropdown({
          previewer = false,
          shorten_path = false,
        }),
        colorscheme = {
          enable_preview = true,
        },
        git_branches = rvim.telescope.dropdown(),
        git_bcommits = {
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        git_commits = {
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        reloader = rvim.telescope.dropdown(),
      },
    },
  })

  --- NOTE: this must be required after setting up telescope
  --- otherwise the result will be cached without the updates
  --- from the setup call
  local builtin = require('telescope.builtin')

  local function notes()
    builtin.find_files({
      prompt_title = 'Notes',
      cwd = vim.fn.expand('~/notes/src/'),
    })
  end

  local function luasnips()
    require('telescope').extensions.luasnip.luasnip(rvim.telescope.dropdown())
  end

  local function find_near_files()
    local cwd = require('telescope.utils').buffer_dir()
    builtin.find_files({
      prompt_title = fmt('Searching %s', fn.fnamemodify(cwd, ':~:.')),
      cwd = cwd,
    })
  end

  local function installed_plugins()
    builtin.find_files({
      prompt_title = 'Installed plugins',
      cwd = join_paths(rvim.get_runtime_dir(), '/site/pack/packer'),
    })
  end

  local function builtins() builtin.builtin({ include_extensions = true }) end

  local function project_files(opts)
    if not pcall(builtin.git_files, opts) then builtin.find_files(opts) end
  end

  local function find_files() builtin.find_files(rvim.telescope.minimal_ui()) end

  local function old_files() builtin.oldfiles(rvim.telescope.minimal_ui()) end

  local function media_files() telescope.extensions.media_files.media_files({}) end

  local function recent_files() telescope.extensions.recent_files.pick(rvim.telescope.minimal_ui()) end

  local function zoxide_list() telescope.extensions.zoxide.list({}) end

  local function frecency()
    require('telescope').extensions.frecency.frecency(rvim.telescope.dropdown({
      previewer = false,
    }))
  end

  local function projects() telescope.extensions.projects.projects({}) end

  local function delta_opts(opts, is_buf)
    local delta = previewers.new_termopen_previewer({
      get_command = function(entry)
        local args = {
          'git',
          '-c',
          'core.pager=delta',
          '-c',
          'delta.side-by-side=false',
          'diff',
          entry.value .. '^!',
        }
        if is_buf then vim.list_extend(args, { '--', entry.current_file }) end
        return args
      end,
    })
    opts = opts or {}
    opts.previewer = {
      delta,
      previewers.git_commit_message.new(opts),
    }
    return opts
  end

  local function delta_git_commits(opts) builtin.git_commits(delta_opts(opts)) end

  local function delta_git_bcommits(opts) builtin.git_bcommits(delta_opts(opts, true)) end

  require('which-key').register({
    ['<c-p>'] = { find_files, 'telescope: find files' },
    ['<leader>gs'] = { builtin.git_status, 'git: status' },
    ['<leader>gf'] = { builtin.git_files, 'git: files' },
    ['<leader>f'] = {
      name = 'Telescope',
      a = { builtins, 'builtin' },
      b = { builtin.current_buffer_fuzzy_find, 'find in current buffer' },
      c = { builtin.resume, 'resume' },
      f = { project_files, 'find files' },
      g = {
        name = 'Git',
        b = { builtin.git_branches, 'branch' },
        B = { delta_git_bcommits, 'buffer commits' },
        c = { delta_git_commits, 'commits' },
      },
      h = { frecency, 'most frequently used files' },
      L = { luasnips, 'luasnip: available snippets' },
      m = { media_files, 'media files' },
      j = { notes, 'notes' },
      n = { find_near_files, 'find near files' },
      o = { old_files, 'old files' },
      p = { projects, 'recent projects' },
      P = { installed_plugins, 'plugins' },
      r = { recent_files, 'resume' },
      R = { builtin.reloader, 'module reloader' },
      s = { builtin.live_grep, 'find string' },
      v = {
        name = 'vim',
        a = { builtin.autocommands, 'autocommands' },
        h = { builtin.highlights, 'highlights' },
        k = { builtin.keymaps, 'keymaps' },
        o = { builtin.vim_options, 'options' },
        r = { builtin.resume, 'resume last picker' },
      },
      w = { builtin.grep_string, 'find current word' },
      z = { zoxide_list, 'zoxide list' },
    },
  })

  vim.api.nvim_exec_autocmds('User', { pattern = 'TelescopeConfigComplete', modeline = false })
end
