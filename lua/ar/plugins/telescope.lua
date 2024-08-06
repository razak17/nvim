local api, env, fn = vim.api, vim.env, vim.fn
local fmt, ui = string.format, ar.ui
local border = ui.border
local datapath = vim.fn.stdpath('data')
local minimal = ar.plugins.minimal
local is_available = ar.is_available
local enabled = not ar.plugin_disabled('telescope.nvim')
local min_enabled = enabled and not minimal

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

---@param opts? table
---@return table
local function cursor(opts)
  return require('telescope.themes').get_cursor(
    vim.tbl_extend('keep', opts or {}, {
      layout_config = { width = 0.4, height = fit_to_available_height },
      borderchars = border.ui_select,
    })
  )
end

---@param opts? table
---@return table
local function horizontal(opts)
  opts = vim.tbl_extend('keep', opts or {}, {
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    layout_config = {
      prompt_position = 'bottom',
    },
  })
  return opts
end

---@param opts? table
---@return table
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

---@param name string
---@return string
local function extension_to_plugin(name)
  return ar.telescope.extension_to_plugin[name]
end

---@param opts? table
---@return function
local function b(picker, opts)
  opts = opts or {}
  return function() require('telescope.builtin')[picker](opts) end
end

-- https://github.com/delphinus/dotfiles/blob/master/.config/nvim/lua/core/telescope/init.lua#L15
---@param name string
---@param prop string?
---@return fun(opts: table?): function
local function extensions(name, prop)
  return function(opts)
    return function(more_opts)
      local o = vim.tbl_extend('force', opts or {}, more_opts or {})
      if not is_available(extension_to_plugin(name)) then
        vim.notify(fmt('%s is not available.', extension_to_plugin(name)))
        return
      end
      require('telescope').extensions[name][prop or name](o)
    end
  end
end

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

local function find_files(opts) extensions('menufacture', 'find_files')(opts)() end

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
    cwd = ar.sync_dir('obsidian'),
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

local function git_files(opts) extensions('menufacture', 'git_files')(opts)() end

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
  extensions('file_browser')(opts)()
end

local function egrepify() extensions('egrepify')({})() end
local function helpgrep() extensions('helpgrep')({})() end
local function frecency(opts)
  opts = vim.tbl_extend('keep', opts or {}, { workspace = 'CWD' })
  extensions('frecency')(opts)()
end
local function luasnips() extensions('luasnip')({})() end
local function notifications() extensions('notify')({})() end
local function undo() extensions('undo')({})() end
local function projects() extensions('projects')(ar.telescope.minimal_ui())() end
local function smart_open()
  extensions('smart_open')({ cwd_only = true, no_ignore = true })()
end
local function directory_files()
  extensions('directory')({ feature = 'find_files' })()
end
local function directory_search()
  extensions('directory')({
    feature = 'live_grep',
    feature_opts = { hidden = true, no_ignore = true },
    hidden = true,
    no_ignore = true,
  })()
end
local function git_file_history() extensions('git_file_history')({})() end
local function lazy() extensions('lazy')({})() end
local function aerial() extensions('aerial')({})() end
local function harpoon()
  extensions('harpoon', 'marks')({ prompt_title = 'Harpoon Marks' })()
end
local function textcase()
  extensions('textcase', 'normal_mode')(ar.telescope.minimal_ui())()
end
local function import() extensions('import')(ar.telescope.minimal_ui())() end
local function whop() extensions('whop')(ar.telescope.minimal_ui())() end
local function node_modules() extensions('node_modules', 'list')({})() end
local function monorepo() extensions('monorepo')({})() end
local function live_grep(opts)
  return extensions('menufacture', 'live_grep')(opts)()
end
local function live_grep_args()
  extensions('live_grep_args')({
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
  })()
end
local function live_grep_args_word()
  local ok, lga_shortcuts = pcall(require, 'telescope-live-grep-args.shortcuts')
  if not ok then
    vim.notify('telescope-live-grep-args.nvim is not installed')
    return
  end
  lga_shortcuts.grep_word_under_cursor()
end
local function live_grep_args_selection()
  local ok, lga_shortcuts = pcall(require, 'telescope-live-grep-args.shortcuts')
  if not ok then
    vim.notify('telescope-live-grep-args.nvim is not installed')
    return
  end
  lga_shortcuts.grep_visual_selection()
end
local function software_licenses()
  extensions('software-licenses', 'find')(ar.telescope.horizontal())()
end

local function visual_grep_string()
  local search = ar.get_visual_text()
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

local function toggle_selection_and_next(prompt_bufnr)
  local actions = require('telescope.actions')
  actions.toggle_selection(prompt_bufnr)
  actions.move_selection_next(prompt_bufnr)
end

-- @see: https://github.com/nvim-telescope/telescope.nvim/issues/1048
-- @see: https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/telescope/init.lua
-- Open multiple files at once
local function multi_selection_open(prompt_bufnr)
  local open_cmd = 'edit'
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not multi or vim.tbl_isempty(multi) then
    actions.add_selection(prompt_bufnr)
  end
  actions.send_selected_to_qflist(prompt_bufnr)
  vim.cmd('cfdo ' .. open_cmd)
end

local function open_media_files()
  local action_state = require('telescope.actions.state')
  local file_path = action_state.get_selected_entry().path
  local media_files = ar.media_files
  local file_extension = file_path:match('^.+%.(.+)$')
  if vim.list_contains(media_files, file_extension) then
    ar.open_media(file_path)
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

-- https://github.com/nvim-telescope/telescope.nvim/issues/2778#issuecomment-2202572413
local focus_preview = function(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt_win = picker.prompt_win
  local previewer = picker.previewer
  local winid = previewer.state.winid
  local bufnr = previewer.state.bufnr
  map(
    'n',
    '<S-Tab>',
    function()
      vim.cmd(
        string.format(
          'noautocmd lua vim.api.nvim_set_current_win(%s)',
          prompt_win
        )
      )
    end,
    { buffer = bufnr }
  )
  vim.cmd(
    string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid)
  )
  -- api.nvim_set_current_win(winid)
end

ar.telescope = {
  extension_to_plugin = {
    ['advanced_git_search'] = 'advanced-git-search.nvim',
    ['aerial'] = 'aerial.nvim',
    ['cmdline'] = 'telescope-cmdline.nvim',
    ['directory'] = 'telescope-directory.nvim',
    ['egrepify'] = 'telescope-egrepify.nvim',
    ['file_browser'] = 'telescope-file-browser.nvim',
    ['frecency'] = 'telescope-frecency.nvim',
    ['git_branch'] = 'telescope-git-branch.nvim',
    ['git_file_history'] = 'git_file_history',
    ['harpoon'] = 'harpoon',
    ['heading'] = 'telescope-heading.nvim',
    ['helpgrep'] = 'telescope-helpgrep.nvim',
    ['lazy'] = 'telescope-lazy.nvim',
    ['live_grep_args'] = 'telescope-live-grep-args.nvim',
    ['luasnip'] = 'LuaSnip',
    ['menufacture'] = 'telescope-menufacture',
    ['monorepo'] = 'monorepo.nvim',
    ['node_modules'] = 'telescope-node-modules.nvim',
    ['notify'] = 'nvim-notify',
    ['persisted'] = 'persisted.nvim',
    ['projects'] = 'project.nvim',
    -- ['smart_history'] = 'telescope-smart-history.nvim',
    ['smart_open'] = 'smart-open.nvim',
    ['software-licenses'] = 'telescope-software-licenses.nvim',
    ['telescope-yaml'] = 'telescope-yaml.nvim',
    ['textcase'] = 'text-case.nvim',
    ['undo'] = 'telescope-undo.nvim',
    ['whop'] = 'whop.nvim',
    ['import'] = 'telescope-import.nvim',
  },
  cursor = cursor,
  dropdown = dropdown,
  horizontal = function(opts)
    opts = opts or {}
    return horizontal(opts)
  end,
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
    'nvim-telescope/telescope-frecency.nvim',
    cond = min_enabled,
    lazy = false,
    config = function() require('telescope').load_extension('frecency') end,
  },
  {
    'nvim-telescope/telescope.nvim',
    cond = enabled,
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
      { '<leader>fga', live_grep_args, desc = 'live-grep-args: grep' },
      { '<leader>fgw', live_grep_args_word, desc = 'live-grep-args: word' },
      { '<leader>fgs', live_grep_args_selection, desc = 'live-grep-args: selection', mode = { 'x' } },
      { '<leader>fgf', directory_files, desc = 'directory for find files' },
      { '<leader>fgg', directory_search, desc = 'directory for live grep' },
      { '<leader>fgh', git_file_history, desc = 'git file history' },
      { '<leader>ff', project_files, desc = 'project files' },
      { '<leader>fh', frecency, desc = 'Most (f)recently used files' },
      { '<leader>fH', helpgrep, desc = 'helpgrep' },
      { '<leader>fi', import, desc = 'import' },
      { '<leader>fI', b('builtin', { include_extensions = true }), desc = 'builtins', },
      { '<leader>fJ', b('jumplist'), desc = 'jumplist', },
      { '<leader>fk', b('keymaps'), desc = 'keymaps' },
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
      { '<leader>fvK', b('colorscheme'), desc = 'colorscheme' },
      { '<leader>fY', b('spell_suggest'), desc = 'spell suggest' },
      { '<leader>fy', '<Cmd>Telescope telescope-yaml<CR>', desc = 'yaml' },
      -- LSP
      { '<leader>ld', b('lsp_document_symbols'), desc = 'telescope: document symbols', },
      { '<leader>lI', b('lsp_implementations'), desc = 'telescope: search implementation', },
      { '<leader>lR', b('lsp_references'), desc = 'telescope: show references', },
      { '<leader>ls', b('lsp_dynamic_workspace_symbols'), desc = 'telescope: workspace symbols', },
      { '<leader>le', b('diagnostics', { bufnr = 0 }), desc = 'telescope: document diagnostics', },
      { '<leader>lw', b('diagnostics'), desc = 'telescope: workspace diagnostics', },
      { '<localleader>ro', monorepo, desc = 'monorepo' },
      { '<leader>fL', software_licenses, desc = 'software licenses' },
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
        filepath = fn.expand(filepath)
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end

      local opts = {
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
              ['<Tab>'] = toggle_selection_and_next,
              ['<CR>'] = stopinsert(actions.select_default),
              ['<C-o>'] = open_media_files,
              ['<A-q>'] = actions.send_to_loclist + actions.open_loclist,
              ['<c-h>'] = actions.results_scrolling_left,
              ['<c-l>'] = actions.results_scrolling_right,
              ['<A-h>'] = actions.preview_scrolling_left,
              ['<A-l>'] = actions.preview_scrolling_right,
              ['<A-u>'] = actions.results_scrolling_up,
              ['<A-d>'] = actions.results_scrolling_down,
              ['<A-j>'] = actions.cycle_history_next,
              ['<A-k>'] = actions.cycle_history_prev,
              ['<c-f>'] = send_find_files_to_live_grep,
              ['<A-;>'] = focus_preview,
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
          menufacture = {
            mappings = { main_menu = { [{ 'i', 'n' }] = '<C-;>' } },
          },
          helpgrep = {
            ignore_paths = { fn.stdpath('state') .. '/lazy/readme' },
          },
        },
      }

      if is_available(extension_to_plugin('frecency')) then
        opts.extensions['frecency'] = {
          db_root = join_paths(datapath, 'databases'),
          default_workspace = 'CWD',
          show_filter_column = false,
          show_scores = true,
          show_unindexed = true,
          ignore_patterns = {
            '*/tmp/*',
            '*node_modules/*',
            '*vendor/*',
          },
          workspaces = {
            conf = vim.g.dotfiles,
            project = vim.g.projects_dir,
          },
        }
      end

      if is_available(extension_to_plugin('live_grep_args')) then
        opts.extensions['live_grep_args'] = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<c-k>'] = require('telescope-live-grep-args.actions').quote_prompt(),
              ['<c-i>'] = require('telescope-live-grep-args.actions').quote_prompt({
                postfix = ' --iglob ',
              }),
              ['<C-r>'] = require('telescope-live-grep-args.actions').to_fuzzy_refine,
            },
          },
        }
      end

      if is_available(extension_to_plugin('smart_open')) then
        opts.extensions['smart_open'] = {
          show_scores = true,
          ignore_patterns = {
            '*.git/*',
            '*/tmp/*',
            '*vendor/*',
            '*node_modules/*',
          },
          match_algorithm = 'fzy',
          disable_devicons = false,
        }
      end

      if is_available(extension_to_plugin('undo')) then
        opts.extensions['undo'] = {
          mappings = {
            i = {
              ['<C-a>'] = require('telescope-undo.actions').yank_additions,
              ['<C-d>'] = require('telescope-undo.actions').yank_deletions,
              ['<C-u>'] = require('telescope-undo.actions').restore,
            },
          },
        }
      end

      if is_available(extension_to_plugin('lazy')) then
        opts.extensions['lazy'] = {
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
        }
      end

      require('telescope').setup(opts)

      local l = require('telescope').load_extension

      for name, ext in pairs(ar.telescope.extension_to_plugin) do
        if name ~= 'frecency' then
          if is_available(ext) then l(name) end
        end
      end

      api.nvim_exec_autocmds(
        'User',
        { pattern = 'TelescopeConfigComplete', modeline = false }
      )
    end,
  },
  { 'molecule-man/telescope-menufacture', cond = min_enabled },
  { 'biozz/whop.nvim', cond = min_enabled, opts = {} },
  { 'nvim-telescope/telescope-node-modules.nvim', cond = min_enabled },
  { 'nvim-telescope/telescope-smart-history.nvim', cond = min_enabled },
  { 'fdschmidt93/telescope-egrepify.nvim', cond = min_enabled },
  { 'debugloop/telescope-undo.nvim', cond = min_enabled },
  { 'nvim-telescope/telescope-file-browser.nvim', cond = min_enabled },
  { 'razak17/telescope-import.nvim', cond = min_enabled },
  { 'catgoose/telescope-helpgrep.nvim', cond = min_enabled },
  { 'razak17/telescope-lazy.nvim', cond = min_enabled },
  { 'fbuchlak/telescope-directory.nvim', cond = min_enabled, opts = {} },
  { 'dapc11/telescope-yaml.nvim', cond = min_enabled },
  { 'crispgm/telescope-heading.nvim', cond = min_enabled },
  { 'chip/telescope-software-licenses.nvim', cond = min_enabled },
  { 'isak102/telescope-git-file-history.nvim', cond = min_enabled },
  {
    'danielfalk/smart-open.nvim', -- use fork to get show_scores working
    cond = enabled,
    dependencies = { 'nvim-telescope/telescope-fzy-native.nvim' },
  },
  {
    'jonarrien/telescope-cmdline.nvim',
    cond = min_enabled and false,
    keys = {
      { ':', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' },
    },
  },
  {
    'mrloop/telescope-git-branch.nvim',
    cond = min_enabled,
    -- stylua: ignore
    keys = {
      { mode = { 'n', 'v' }, '<leader>gf', function() require('git_branch').files() end, desc = 'git branch' },
    },
  },
  {
    'nvim-telescope/telescope-live-grep-args.nvim',
    cond = min_enabled,
    version = '^1.0.0',
  },
  {
    'Myzel394/jsonfly.nvim',
    cond = min_enabled,
    ft = { 'json' },
    keys = {
      { '<leader>fj', '<Cmd>Telescope jsonfly<cr>', desc = 'Open json(fly)' },
    },
  },
  {
    'imNel/monorepo.nvim',
    cond = enabled,
    opts = {},
    -- stylua: ignore
    keys = {
      { '<localleader>ra', ':lua require("monorepo").add_project()<CR>', desc = 'monorepo: add' },
      { '<localleader>rr', ':lua require("monorepo").remove_project()<CR>', desc = 'monorepo: remove' },
      { '<localleader>rt', ':lua require("monorepo").toggle_project()<CR>', desc = 'monorepo: toggle' },
      { '<localleader>rp', ':lua require("monorepo").previous_project()<CR>', desc = 'monorepo: previous' },
      { '<localleader>rn', ':lua require("monorepo").next_project()<CR>', desc = 'monorepo: next' },
    },
  },
  {
    'dimaportenko/project-cli-commands.nvim',
    cond = min_enabled,
    -- stylua: ignore
    keys = {
      { '<localleader>Po', ':Telescope project_cli_commands open<CR>', desc = 'project-cli-commands: open' },
      { '<localleader>Ps', ':Telescope project_cli_commands running<CR>', desc = 'project-cli-commands: running' },
    },
    config = function() require('project_cli_commands').setup({}) end,
  },
}
