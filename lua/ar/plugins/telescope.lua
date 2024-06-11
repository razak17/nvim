local api, env, fn = vim.api, vim.env, vim.fn
local fmt, ui = string.format, rvim.ui
local border = ui.border
local datapath = vim.fn.stdpath('data')
local minimal = rvim.plugins.minimal

-- A helper function to limit the size of a telescope window to fit the maximum available
-- space on the screen. This is useful for dropdowns e.g. the cursor or dropdown theme
local function fit_to_available_height(self, _, max_lines)
  local results, PADDING = #self.finder.results, 4 -- this represents the size of the telescope window
  local LIMIT = math.floor(max_lines / 2)
  return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
end

---@param opts? table
---@return table
local function dropdown(opts)
  opts = opts or {}
  opts.borderchars = border.ui_select
  return require('telescope.themes').get_dropdown(opts)
end

local function cursor(opts)
  return require('telescope.themes').get_cursor(
    vim.tbl_extend('keep', opts or {}, {
      layout_config = { width = 0.4, height = fit_to_available_height },
      borderchars = border.ui_select,
    })
  )
end

local function vertical(opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    sorting_strategy = 'ascending',
    layout_strategy = 'vertical',
    layout_config = {
      width = 0.7,
      height = 0.9,
      prompt_position = 'bottom',
      preview_cutoff = 20,
      preview_height = function(_, _, max_lines) return max_lines - 20 end,
    },
  })
  return opts
end

local function extensions(name) return require('telescope').extensions[name] end

local function delta_opts(opts, is_buf)
  local previewers = require('telescope.previewers')
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
  opts.previewer = { delta, previewers.git_commit_message.new(opts) }
  return opts
end

local function live_grep(opts) return extensions('menufacture').live_grep(opts) end
local function find_files(opts)
  return extensions('menufacture').find_files(opts)
end

local function nvim_config()
  find_files({
    prompt_title = '~ rVim config ~',
    cwd = fn.stdpath('config'),
    file_ignore_patterns = { '.git/.*', 'dotbot/.*', 'zsh/plugins/.*' },
  })
end

local function notes()
  find_files({
    prompt_title = '~ Obsidian ~',
    cwd = rvim.sync('obsidian'),
    file_ignore_patterns = {
      '.git/.*',
      'dotbot/.*',
      'zsh/plugins/.*',
      '.obsidian',
      '.trash',
    },
  })
end

local function plugins()
  find_files({
    prompt_title = '~ Plugins ~',
    cwd = fn.stdpath('data') .. '/lazy',
    file_ignore_patterns = { '.git/.*', 'dotbot/.*', 'zsh/plugins/.*' },
  })
end
local function git_files(opts) return extensions('menufacture').git_files(opts) end

local function project_files()
  if not pcall(git_files, { show_untracked = true }) then find_files() end
end

local function file_browser(opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    hidden = true,
    no_ignore = true,
    sort_mru = true,
    sort_lastused = true,
  })
  extensions('file_browser').file_browser(opts)
end

local function egrepify() extensions('egrepify').egrepify() end
local function helpgrep() extensions('helpgrep').helpgrep() end
local function frecency(opts)
  opts = opts or {}
  extensions('frecency').frecency(opts)
end
local function luasnips() extensions('luasnip').luasnip() end
local function notifications() extensions('notify').notify() end
local function undo() extensions('undo').undo() end
local function projects()
  extensions('projects').projects(rvim.telescope.minimal_ui())
end
local function smart_open()
  extensions('smart_open').smart_open({ cwd_only = true, no_ignore = true })
end
local function directory_files()
  extensions('directory').directory({ feature = 'find_files' })
end
local function directory_search()
  extensions('directory').directory({
    feature = 'live_grep',
    feature_opts = { hidden = true, no_ignore = true },
    hidden = true,
    no_ignore = true,
  })
end
local function git_file_history()
  extensions('git_file_history').git_file_history()
end
local function lazy() extensions('lazy').lazy() end
local function aerial() extensions('aerial').aerial() end
local function harpoon()
  extensions('harpoon').marks({ prompt_title = 'Harpoon Marks' })
end
local function textcase()
  extensions('textcase').normal_mode(rvim.telescope.minimal_ui())
end
local function import() extensions('import').import(rvim.telescope.minimal_ui()) end
local function whop() extensions('whop').whop(rvim.telescope.minimal_ui()) end
local function node_modules() extensions('node_modules').list() end
local function live_grep_args()
  extensions('live_grep_args').live_grep_args({
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

---@param opts? table
---@return function
local function b(picker, opts)
  opts = opts or {}
  return function() require('telescope.builtin')[picker](opts) end
end

local function visual_grep_string()
  local search = rvim.get_visual_text()
  if type(search) == 'string' then
    b('grep_string')({
      search = search,
      prompt_title = 'Searh: ' .. string.sub(search, 0, 20),
    })
  end
end

local function stopinsert(callback)
  return function(prompt_bufnr)
    vim.cmd.stopinsert()
    vim.schedule(function() callback(prompt_bufnr) end)
  end
end

-- @see: https://github.com/nvim-telescope/telescope.nvim/issues/1048
-- @see: https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/telescope/init.lua
-- Open multiple files at once
local function multiopen(prompt_bufnr, open_cmd)
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = #picker:get_multi_selection()
  if not num_selections or num_selections <= 1 then
    actions.add_selection(prompt_bufnr)
  end
  actions.send_selected_to_qflist(prompt_bufnr)
  vim.cmd('cfdo ' .. open_cmd)
end

local function multi_selection_open(prompt_bufnr)
  multiopen(prompt_bufnr, 'edit')
end

local function open_media_files()
  local action_state = require('telescope.actions.state')
  local file_path = action_state.get_selected_entry().path
  local media_files = rvim.media_files
  local file_extension = file_path:match('^.+%.(.+)$')
  if vim.list_contains(media_files, file_extension) then
    rvim.open_media(file_path)
  else
    vim.notify('Not a media file')
  end
end

-- Ref; https://www.reddit.com/r/neovim/comments/1dajad0/find_files_live_grep_in_telescope/
local send_find_files_to_live_grep = function()
  local results = {}
  local prompt_bufnr = vim.api.nvim_get_current_buf()
  require('telescope.actions.utils').map_entries(
    prompt_bufnr,
    function(entry, _, _) table.insert(results, entry[0] or entry[1]) end
  )
  require('telescope.builtin').live_grep({ search_dirs = results })
end

rvim.telescope = {
  cursor = cursor,
  dropdown = dropdown,
  vertical = function(opts)
    opts = opts or {}
    return vertical(opts)
  end,
  adaptive_dropdown = function()
    return dropdown({ height = fit_to_available_height })
  end,
  minimal_ui = function(opts)
    opts = opts or {}
    vim.tbl_extend('keep', opts, { previewer = false })
    return dropdown(opts)
  end,
  delta_opts = delta_opts,
}

return {
  {
    'nvim-telescope/telescope.nvim',
    -- NOTE: usind cmd causes issues with dressing and frecency
    cmd = { 'Telescope' },
    -- event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      -- { '<c-p>', find_files, desc = 'find files' },
      { '<c-p>', smart_open, desc = 'find files' },
      { '<leader>f,', file_browser, desc = 'file browser' },
      { '<leader>f.', function() file_browser({ path = '%:p:h', select_buffer = 'true' }) end, desc = 'file browser', },
      { '<leader>f?', b('help_tags'), desc = 'help tags' },
      { '<leader>fb', b('buffers'), desc = 'buffers' },
      -- { '<leader>fb', b('current_buffer_fuzzy_find'), desc = 'find in current buffer', },
      { '<leader>fc', nvim_config, desc = 'nvim config' },
      { '<leader>fd', aerial, desc = 'aerial' },
      { '<leader>fe', egrepify, desc = 'egrepify' },
      { '<leader>fga', live_grep_args, desc = 'live grep args' },
      { '<leader>fgf', directory_files, desc = 'directory for find files' },
      { '<leader>fgg', directory_search, desc = 'directory for live grep' },
      { '<leader>fgh', git_file_history, desc = 'git file history' },
      { '<leader>ff', project_files, desc = 'project files' },
      { '<leader>fh', frecency, desc = 'Most (f)recently used files' },
      { '<leader>fH', helpgrep, desc = 'helpgrep' },
      { '<leader>fi', import, desc = 'import' },
      { '<leader>fI', b('builtin', { include_extensions = true }), desc = 'builtins', },
      { '<leader>fJ', b('jumplist'), desc = 'jumplist', },
      { '<leader>fk', b('keymaps'), desc = 'autocommands' },
      { '<leader>fl', lazy, desc = 'surf plugins' },
      { '<leader>fL', luasnips, desc = 'luasnip: available snippets' },
      { '<leader>fn', notifications, desc = 'notify: notifications' },
      { '<leader>fN', node_modules, desc = 'node_modules' },
      { '<leader>fo', b('pickers'), desc = 'pickers' },
      { '<leader>fO', notes, desc = 'notes' },
      -- { '<leader>fO', b('oldfiles'), desc = 'oldfiles' },
      { '<leader>fp', projects, desc = 'projects' },
      { '<leader>fP', plugins, desc = 'plugins' },
      {
        '<leader>fq',
        function()
          b('quickfix')()
          vim.cmd(':cclose')
        end,
        desc = 'quickfix list',
      },
      { '<leader>fr', b('resume'), desc = 'resume last picker' },
      { '<leader>fs', live_grep, desc = 'find string' },
      { '<leader>fs', visual_grep_string, desc = 'find word', mode = 'x' },
      { '<leader>fu', undo, desc = 'undo' },
      { '<leader>fm', harpoon, desc = 'harpoon' },
      { '<leader>ft', textcase, desc = 'textcase', mode = { 'n', 'v' } },
      { '<leader>fw', b('grep_string'), desc = 'find word' },
      { '<leader>fW', whop, desc = 'whop' },
      { '<leader>fva', b('autocommands'), desc = 'autocommands' },
      { '<leader>fvc', b('commands'), desc = 'commands' },
      { '<leader>fvh', b('highlights'), desc = 'highlights' },
      { '<leader>fvo', b('vim_options'), desc = 'vim options' },
      { '<leader>fvr', b('registers'), desc = 'registers' },
      { '<leader>fvk', b('command_history'), desc = 'command history' },
      { '<leader>fY', b('spell_suggest'), desc = 'spell suggest' },
      { '<leader>fy', '<Cmd>Telescope telescope-yaml<CR>', desc = 'yaml' },
      -- LSP
      { '<leader>ld', b('lsp_document_symbols'), desc = 'telescope: document symbols', },
      { '<leader>lI', b('lsp_implementations'), desc = 'telescope: search implementation', },
      { '<leader>lR', b('lsp_references'), desc = 'telescope: show references', },
      { '<leader>ls', b('lsp_dynamic_workspace_symbols'), desc = 'telescope: workspace symbols', },
      { '<leader>le', b('diagnostics', { bufnr = 0 }), desc = 'telescope: document diagnostics', },
      { '<leader>lw', b('diagnostics'), desc = 'telescope: workspace diagnostics', },
    },
    config = function()
      local previewers = require('telescope.previewers')
      local sorters = require('telescope.sorters')
      local actions = require('telescope.actions')
      local layout_actions = require('telescope.actions.layout')
      local themes = require('telescope.themes')
      local config = require('telescope.config')
      local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }

      table.insert(vimgrep_arguments, '--hidden')
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!**/.git/*')

      local ignore_preview = { '.*%.csv', '.*%.java' }
      local previewer_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        opts.use_ft_detect = opts.use_ft_detect or true
        -- if the file is too large, don't use the ft detect
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, filepath)
        if ok and stats and stats.size > max_filesize then
          opts.use_ft_detect = false
        end
        -- if the file is in the ignore list, don't use the ft detect
        vim.iter(ignore_preview):map(function(item)
          if filepath:match(item) then
            opts.use_ft_detect = false
            return
          end
        end)
        filepath = vim.fn.expand(filepath)
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end

      require('telescope').setup({
        defaults = {
          prompt_prefix = fmt(' %s  ', ui.codicons.misc.search_alt),
          selection_caret = fmt(' %s', ui.icons.misc.separator),
          -- ref: LazyVim
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = api.nvim_list_wins()
            table.insert(wins, 1, api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == '' then return win end
            end
            return 0
          end,
          cycle_layout_list = {
            'flex',
            'horizontal',
            'vertical',
            'bottom_pane',
            'center',
          },
          vimgrep_arguments = vimgrep_arguments,
          buffer_previewer_maker = previewer_maker,
          sorting_strategy = 'ascending',
          layout_strategy = 'flex',
          set_env = { ['TERM'] = env.TERM },
          borderchars = border.common,
          file_browser = { hidden = true },
          color_devicons = true,
          dynamic_preview_title = true,
          results_title = false,
          layout_config = { horizontal = { preview_width = 0.55 } },
          winblend = 0,
          history = {
            limit = 100,
            path = join_paths(
              datapath,
              'databases',
              'telescope_history.sqlite3'
            ),
          },
          cache_picker = { num_pickers = 3 },
          file_ignore_patterns = {
            '%.jpg',
            '%.jpeg',
            '%.png',
            '%.otf',
            '%.ttf',
            '%.DS_Store',
            '/%.git/',
            '^%.git/',
            '/node_modules/',
            '^node_modules/',
            'dist/',
            'env/',
            'venv/',
            'build/',
            'site-packages/',
            '%.yarn/',
            '^__pycache__/',
            '.obsidian',
          },
          path_display = { 'filename_first' },
          file_sorter = sorters.get_fzy_sorter,
          file_previewer = previewers.vim_buffer_cat.new,
          grep_previewer = previewers.vim_buffer_vimgrep.new,
          qflist_previewer = previewers.vim_buffer_qflist.new,
          mappings = {
            i = {
              ['<c-c>'] = function() vim.cmd.stopinsert() end,
              ['<c-j>'] = actions.move_selection_next,
              ['<c-k>'] = actions.move_selection_previous,
              ['<esc>'] = actions.close,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<c-s>'] = actions.select_horizontal,
              ['<c-e>'] = layout_actions.toggle_preview,
              ['<A-[>'] = layout_actions.cycle_layout_next,
              ['<A-]>'] = layout_actions.cycle_layout_next,
              ['<C-a>'] = multi_selection_open,
              ['<c-r>'] = actions.to_fuzzy_refine,
              ['<Tab>'] = actions.toggle_selection,
              ['<CR>'] = stopinsert(actions.select_default),
              ['<C-o>'] = open_media_files,
              ['<A-q>'] = actions.send_to_loclist + actions.open_loclist,
              ['<c-h>'] = actions.results_scrolling_left,
              ['<c-l>'] = actions.results_scrolling_right,
              ['<A-h>'] = actions.preview_scrolling_left,
              ['<A-l>'] = actions.preview_scrolling_right,
              ['<A-u>'] = actions.results_scrolling_up,
              ['<A-d>'] = actions.results_scrolling_down,
              ['<c-f>'] = send_find_files_to_live_grep,
            },
            n = {
              ['<c-n>'] = actions.move_selection_next,
              ['<c-p>'] = actions.move_selection_previous,
            },
          },
          preview = {
            filesize_limit = 0.5, -- MB
          },
        },
        pickers = {
          registers = cursor(),
          reloader = dropdown(),
          git_branches = dropdown(),
          oldfiles = dropdown({ previewer = false }),
          spell_suggest = dropdown({ previewer = false }),
          find_files = {
            -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
            find_command = {
              'rg',
              '--files',
              '--hidden',
              '--glob',
              '!**/.git/*',
            },
            no_ignore = true,
          },
          colorscheme = { enable_preview = true },
          keymaps = dropdown({ layout_config = { height = 18, width = 0.5 } }),
          git_commits = {
            layout_config = { horizontal = { preview_width = 0.55 } },
          },
          git_bcommits = {
            layout_config = { horizontal = { preview_width = 0.55 } },
          },
          current_buffer_fuzzy_find = dropdown({
            previewer = false,
            shorten_path = false,
          }),
          diagnostics = themes.get_ivy({
            wrap_results = true,
            borderchars = { preview = border.ivy },
          }),
          buffers = dropdown({
            sort_mru = true,
            sort_lastused = true,
            show_all_buffers = true,
            ignore_current_buffer = true,
            previewer = false,
            mappings = {
              i = { ['<c-x>'] = 'delete_buffer' },
              n = { ['<c-x>'] = 'delete_buffer' },
            },
          }),
          live_grep = {
            file_ignore_patterns = {
              '%.svg',
              '%.lock',
              '%-lock.yaml',
              '%-lock.json',
            },
            max_results = 2000,
            additional_args = { '--trim' },
          },
        },
        extensions = {
          persisted = dropdown(),
          frecency = {
            db_root = join_paths(datapath, 'databases'),
            default_workspace = 'CWD',
            show_unindexed = false, -- Show all files or only those that have been indexed
            ignore_patterns = {
              '**',
              '*/tmp/*',
              '*node_modules/*',
              '*vendor/*',
            },
            workspaces = {
              conf = env.DOTFILES,
              project = vim.g.projects_dir,
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
          menufacture = {
            mappings = { main_menu = { [{ 'i', 'n' }] = '<C-;>' } },
          },
          helpgrep = {
            ignore_paths = {
              fn.stdpath('state') .. '/lazy/readme',
            },
          },
          lazy = {
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
          smart_open = {
            show_scores = false,
            ignore_patterns = {
              '*.git/*',
              '*/tmp/*',
              '*vendor/*',
              '*node_modules/*',
            },
            match_algorithm = 'fzy',
            disable_devicons = false,
          },
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
              i = {
                ['<M-y>'] = require('telescope-live-grep-args.actions').quote_prompt(),
                ['<M-u>'] = require('telescope-live-grep-args.actions').quote_prompt({
                  postfix = ' --iglob ',
                }),
              },
              n = {
                ['<M-y>'] = require('telescope-live-grep-args.actions').quote_prompt(),
                ['<M-u>'] = require('telescope-live-grep-args.actions').quote_prompt({
                  postfix = ' --iglob ',
                }),
              },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
          },
        },
      })

      local l = require('telescope').load_extension
      local exts = {
        ['text-case.nvim'] = 'textcase',
        ['harpoon'] = 'harpoon',
        ['nvim-notify'] = 'notify',
        ['persisted.nvim'] = 'persisted',
        ['project.nvim'] = 'projects',
        ['advanced-git-search.nvim'] = 'advanced_git_search',
      }

      for ext, name in pairs(exts) do
        if rvim.is_available(ext) then l(name) end
      end

      api.nvim_exec_autocmds(
        'User',
        { pattern = 'TelescopeConfigComplete', modeline = false }
      )
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-frecency.nvim',
        config = function() require('telescope').load_extension('frecency') end,
      },
      {
        'molecule-man/telescope-menufacture',
        config = function() require('telescope').load_extension('menufacture') end,
      },
    },
  },
  {
    'biozz/whop.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function()
      require('whop').setup({})
      require('telescope').load_extension('whop')
    end,
  },
  {
    'danielfalk/smart-open.nvim',
    branch = '0.2.x',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('smart_open') end,
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope-fzy-native.nvim',
    },
  },
  {
    'jonarrien/telescope-cmdline.nvim',
    cond = not minimal and false,
    cmd = 'Telescope',
    keys = {
      { ':', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' },
    },
    config = function() require('telescope').load_extension('cmdline') end,
  },
  {
    'nvim-telescope/telescope-node-modules.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('node_modules') end,
  },
  {
    'nvim-telescope/telescope-smart-history.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('smart_history') end,
    dependencies = 'kkharji/sqlite.lua',
  },
  {
    'fdschmidt93/telescope-egrepify.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('egrepify') end,
  },
  {
    'debugloop/telescope-undo.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('undo') end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('file_browser') end,
  },
  {
    -- 'piersolenski/telescope-import.nvim',
    'razak17/telescope-import.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('import') end,
  },
  {
    'catgoose/telescope-helpgrep.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('helpgrep') end,
  },
  {
    -- 'tsakirist/telescope-lazy.nvim',
    'razak17/telescope-lazy.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('lazy') end,
  },
  {
    'fbuchlak/telescope-directory.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('directory') end,
    opts = {},
  },
  {
    'isak102/telescope-git-file-history.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('git_file_history') end,
    dependencies = { 'tpope/vim-fugitive' },
  },
  {
    'nvim-telescope/telescope-live-grep-args.nvim',
    cmd = 'Telescope',
    version = '^1.0.0',
    config = function() require('telescope').load_extension('live_grep_args') end,
  },
  {
    'dapc11/telescope-yaml.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('telescope-yaml') end,
  },
  {
    'crispgm/telescope-heading.nvim',
    cond = not minimal,
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('heading') end,
  },
  {
    'Myzel394/jsonfly.nvim',
    cond = rvim.lsp.enable and not minimal,
    cmd = 'Telescope',
    ft = { 'json' },
    keys = {
      { '<leader>fj', '<Cmd>Telescope jsonfly<cr>', desc = 'Open json(fly)' },
    },
  },
}
