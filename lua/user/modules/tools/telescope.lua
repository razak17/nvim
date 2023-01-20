local M = {
  'nvim-telescope/telescope.nvim',
  event = 'CursorHold',
  dependencies = {
    'jvgrootveld/telescope-zoxide',
    'smartpde/telescope-recent-files',
    'nvim-telescope/telescope-media-files.nvim',
    'nvim-telescope/telescope-dap.nvim',
    'natecraddock/telescope-zf-native.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'benfowler/telescope-luasnip.nvim',
    'nvim-telescope/telescope-frecency.nvim',
    'debugloop/telescope-undo.nvim',
  },
}

function M.init()
  local telescope = require('telescope')
  local previewers = require('telescope.previewers')

  local fmt, fn = string.format, vim.fn

  local builtin = require('telescope.builtin')

  local function luasnips() telescope.extensions.luasnip.luasnip(rvim.telescope.dropdown()) end

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
      cwd = join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy'),
    })
  end

  local function builtins() builtin.builtin({ include_extensions = true }) end

  local function project_files(opts)
    if not pcall(builtin.git_files, opts) then builtin.find_files(opts) end
  end

  local function find_files() builtin.find_files(rvim.telescope.minimal_ui()) end

  local function media_files() telescope.extensions.media_files.media_files({}) end

  local function zoxide_list() telescope.extensions.zoxide.list(rvim.telescope.minimal_ui()) end

  local function frecency()
    telescope.extensions.frecency.frecency(rvim.telescope.dropdown(rvim.telescope.minimal_ui()))
  end

  local function recent_files()
    telescope.extensions.recent_files.pick(rvim.telescope.dropdown(rvim.telescope.minimal_ui()))
  end

  local function notifications() telescope.extensions.notify.notify(rvim.telescope.dropdown()) end

  -- FIXME: <C-cr> mapping does not work
  local function undo() telescope.extensions.undo.undo() end

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

  local nnoremap = rvim.nnoremap
  nnoremap('<c-p>', find_files, 'telescope: find files')
  nnoremap('<leader>fa', builtins, 'telescope: builtins')
  nnoremap('<leader>fb', builtin.current_buffer_fuzzy_find, 'find in current buffer')
  nnoremap('<leader>fc', builtin.resume, 'resume last picker')
  nnoremap('<leader>ff', project_files, 'telescope: project files')
  nnoremap('<leader>fh', frecency, 'Most (f)recently used files')
  nnoremap('<leader>fL', luasnips, 'luasnip: available snippets')
  nnoremap('<leader>fm', media_files, 'telescope: media files')
  nnoremap('<leader>fn', notifications, 'notifications')
  nnoremap('<leader>f?', builtin.help_tags, 'help')
  nnoremap('<leader>ffn', find_near_files, 'find near files')
  nnoremap('<leader>fo', builtin.buffers, 'buffers')
  nnoremap('<leader>fp', projects, 'projects')
  nnoremap('<leader>fP', installed_plugins, 'plugins')
  nnoremap('<leader>fr', recent_files, 'recent files')
  nnoremap('<leader>fR', builtin.reloader, 'module reloader')
  nnoremap('<leader>fs', builtin.live_grep, 'find string')
  nnoremap('<leader>fu', undo, 'undo')
  nnoremap('<leader>fva', builtin.autocommands, 'autocommands')
  nnoremap('<leader>fvh', builtin.highlights, 'highlights')
  nnoremap('<leader>fvk', builtin.keymaps, 'keymaps')
  nnoremap('<leader>fvo', builtin.vim_options, 'options')
  nnoremap('<leader>fw', builtin.grep_string, 'find word')
  nnoremap('<leader>fz', zoxide_list, 'zoxide')
  -- Git
  nnoremap('<leader>gf', builtin.git_files, 'git files')
  nnoremap('<leader>gs', builtin.git_status, 'git status')
  nnoremap('<leader>fgb', builtin.git_branches, 'git branches')
  nnoremap('<leader>fgB', delta_git_bcommits, 'buffer commits')
  nnoremap('<leader>fgc', delta_git_commits, 'commits')
  -- LSP
  nnoremap('<leader>ld', builtin.lsp_document_symbols, 'telescope: document symbols')
  nnoremap('<leader>ls', builtin.lsp_dynamic_workspace_symbols, 'telescope: workspace symbols')
  nnoremap(
    '<leader>le',
    '<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<CR>',
    'telescope: document diagnostics'
  )
  nnoremap(
    '<leader>lw',
    '<cmd>Telescope diagnostics theme=get_ivy<CR>',
    'telescope: workspace diagnostics'
  )

  local function cmd(alias, command)
    return vim.api.nvim_create_user_command(alias, command, { nargs = 0 })
  end

  cmd('WebSearch', function()
    local search = vim.fn.input('Search: ')
    local pickers = require('telescope.pickers')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values

    local searcher = function(opts)
      opts = opts or {}
      pickers
        .new(opts, {
          prompt_title = 'Web Search',
          finder = finders.new_table({
            results = {
              {
                'Google Search',
                ('https://www.google.com/search?q=' .. search:gsub(' ', '+')),
              },
              {
                'DuckDuckGo',
                ('https://html.duckduckgo.com/html?q=' .. search:gsub(' ', '+')),
              },
              {
                'Youtube',
                ('https://www.youtube.com/results?search_query=' .. search:gsub(' ', '+')),
              },
              { 'Github', ('https://github.com/search?q=' .. search:gsub(' ', '+')) },
            },
            entry_maker = function(entry)
              return { value = entry, display = entry[1], ordinal = entry[1] }
            end,
          }),
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              rvim.open(selection['value'][2])
            end)
            return true
          end,
        })
        :find()
    end
    searcher(rvim.telescope.minimal_ui())
  end)
  nnoremap('<leader>fd', '<cmd>WebSearch<CR>', 'web search')
end

function M.config()
  local previewers = require('telescope.previewers')
  local sorters = require('telescope.sorters')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local layout_actions = require('telescope.actions.layout')
  local themes = require('telescope.themes')
  local icons = rvim.style.icons
  local border = rvim.style.border
  local fmt = string.format

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
    return themes.get_dropdown(vim.tbl_deep_extend('force', opts or {}, {
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
    return themes.get_ivy(vim.tbl_deep_extend('keep', opts or {}, {
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
      prompt_prefix = fmt(' %s  ', icons.misc.search_alt),
      selection_caret = fmt(' %s  ', icons.misc.pick),
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
      history = { path = join_paths(rvim.get_runtime_dir(), 'telescope', 'history.sqlite3') },
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
      find_files = { hidden = true },
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
        file_ignore_patterns = { '.git/', '%.html', 'dotbot/.*', 'zsh/plugins/.*' },
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
        db_root = join_paths(rvim.get_runtime_dir(), 'telescope'),
        default_workspace = 'CWD',
        show_unindexed = false, -- Show all files or only those that have been indexed
        ignore_patterns = { '*.git/*', '*/tmp/*', '*node_modules/*', '*vendor/*' },
        workspaces = {
          conf = vim.env.DOTFILES,
          project = vim.env.DEV_HOME,
        },
      },
      undo = {
        mappings = {
          i = {
            ['<C-a>'] = require('telescope-undo.actions').yank_additions,
            ['<C-d>'] = require('telescope-undo.actions').yank_deletions,
            ['<C-u>'] = require('telescope-undo.actions').restore,
          },
        },
      },
      recent_files = { only_cwd = true },
    },
  })

  require('telescope').load_extension('zoxide')
  require('telescope').load_extension('recent_files')
  require('telescope').load_extension('media_files')
  require('telescope').load_extension('dap')
  require('telescope').load_extension('zf-native')
  require('telescope').load_extension('ui-select')
  require('telescope').load_extension('luasnip')
  require('telescope').load_extension('frecency')
  require('telescope').load_extension('undo')

  vim.api.nvim_exec_autocmds('User', { pattern = 'TelescopeConfigComplete', modeline = false })
end

return M
