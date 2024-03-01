local api, env, fn = vim.api, vim.env, vim.fn
local fmt, ui = string.format, rvim.ui
local border = ui.border
local data = vim.fn.stdpath('data')

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

-- local function live_grep(opts) return extensions('menufacture').live_grep(opts) end
local function find_files(opts)
  return extensions('menufacture').find_files(opts)
end
-- local function git_files(opts) return extensions('menufacture').git_files(opts) end

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
    cwd = env.HOME .. '/Sync/notes/obsidian',
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

-- local function project_files()
--   if not pcall(git_files, { show_untracked = true }) then find_files() end
-- end

local function file_browser(opts)
  opts = opts
    or {
      hidden = true,
      sort_mru = true,
      sort_lastused = true,
    }
  extensions('file_browser').file_browser(opts)
end

local function egrepify() extensions('egrepify').egrepify() end
local function helpgrep() extensions('helpgrep').helpgrep() end
local function frecency() extensions('frecency').frecency() end
local function luasnips() extensions('luasnip').luasnip() end
local function notifications() extensions('notify').notify() end
local function undo() extensions('undo').undo() end
local function projects()
  extensions('projects').projects(rvim.telescope.minimal_ui())
end
local function smart_open()
  extensions('smart_open').smart_open({ cwd_only = true })
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

---@param opts? table
---@return function
local function b(picker, opts)
  opts = opts or {}
  return function() require('telescope.builtin')[picker](opts) end
end

local function vtext()
  local a_orig = vim.fn.getreg('a')
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then vim.cmd([[normal! gv]]) end

  vim.cmd([[normal! "aygv]])
  local text = vim.fn.getreg('a')
  vim.fn.setreg('a', a_orig)
  return text
end

local function visual_grep_string()
  local search = vtext()
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

local function open_media_files(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  local file_path = action_state.get_selected_entry(prompt_bufnr).path
  local media_files = rvim.media_files
  local file_extension = file_path:match('^.+%.(.+)$')
  if vim.list_contains(media_files, file_extension) then
    rvim.open_media(file_path)
  else
    vim.notify('Not a media file')
  end
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
    -- cmd = 'Telescope',
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      -- { '<c-p>', find_files, desc = 'find files' },
      { '<c-p>', smart_open, desc = 'find files' },
      { '<leader>f,', file_browser, desc = 'file browser' },
      { '<leader>f.', function() file_browser({ path = '%:p:h', select_buffer = 'true' }) end, desc = 'file browser', },
      { '<leader>f?', b('help_tags'), desc = 'help tags' },
      { '<leader>fa', b('autocommands'), desc = 'autocommands' },
      { '<leader>fb', b('buffers'), desc = 'buffers' },
      -- { '<leader>fb', b('current_buffer_fuzzy_find'), desc = 'find in current buffer', },
      { '<leader>fc', nvim_config, desc = 'nvim config' },
      { '<leader>fd', aerial, desc = 'aerial' },
      { '<leader>fgf', directory_files, desc = 'directory for find files' },
      { '<leader>fgg', directory_search, desc = 'directory for live grep' },
      { '<leader>fe', egrepify, desc = 'aerial' },
      -- { '<leader>ff', project_files, desc = 'project files' },
      { '<leader>fh', frecency, desc = 'Most (f)recently used files' },
      { '<leader>fH', helpgrep, desc = 'helpgrep' },
      { '<leader>fi', import, desc = 'import' },
      { '<leader>fI', b('builtin', { include_extensions = true }), desc = 'builtins', },
      { '<leader>fj', whop, desc = 'whop' },
      { '<leader>fk', b('keymaps'), desc = 'autocommands' },
      { '<leader>fl', lazy, desc = 'surf plugins' },
      { '<leader>fL', luasnips, desc = 'luasnip: available snippets' },
      { '<leader>fn', notifications, desc = 'notify: notifications' },
      { '<leader>fN', notes, desc = 'notes' },
      { '<leader>fo', b('pickers'), desc = 'pickers' },
      { '<leader>fO', b('oldfiles'), desc = 'oldfiles' },
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
      -- { '<leader>fs', live_grep, desc = 'find string' },
      { '<leader>fu', undo, desc = 'undo' },
      { '<leader>fm', harpoon, desc = 'harpoon' },
      { '<leader>ft', textcase, desc = 'textcase', mode = { 'n', 'v' } },
      { '<leader>fw', b('grep_string'), desc = 'find word' },
      { '<leader>fw', visual_grep_string, desc = 'find word', mode = 'x' },
      { '<leader>fvc', b('commands'), desc = 'commands' },
      { '<leader>fvh', b('highlights'), desc = 'highlights' },
      { '<leader>fvo', b('vim_options'), desc = 'vim options' },
      { '<leader>fvr', b('registers'), desc = 'registers' },
      { '<leader>fy', b('spell_suggest'), desc = 'spell suggest' },
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
          sorting_strategy = 'ascending',
          layout_strategy = 'flex',
          set_env = { ['TERM'] = env.TERM },
          borderchars = border.common,
          file_browser = { hidden = true },
          color_devicons = true,
          dynamic_preview_title = true,
          layout_config = { horizontal = { preview_width = 0.55 } },
          winblend = 0,
          history = {
            path = join_paths(data, 'databases', 'telescope_history.sqlite3'),
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
          path_display = { 'truncate' },
          file_sorter = sorters.get_fzy_sorter,
          file_previewer = previewers.vim_buffer_cat.new,
          grep_previewer = previewers.vim_buffer_vimgrep.new,
          qflist_previewer = previewers.vim_buffer_qflist.new,
          mappings = {
            i = {
              ['<C-w>'] = actions.send_selected_to_qflist,
              ['<c-c>'] = function() vim.cmd.stopinsert() end,
              ['<c-j>'] = actions.move_selection_next,
              ['<c-k>'] = actions.move_selection_previous,
              ['<esc>'] = actions.close,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<c-s>'] = actions.select_horizontal,
              ['<c-e>'] = layout_actions.toggle_preview,
              ['<c-l>'] = layout_actions.cycle_layout_next,
              ['<C-a>'] = multi_selection_open,
              ['<c-r>'] = actions.to_fuzzy_refine,
              ['<Tab>'] = actions.toggle_selection,
              ['<CR>'] = stopinsert(actions.select_default),
              ['<C-o>'] = open_media_files,
            },
            n = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<C-a>'] = multi_selection_open,
              ['<c-n>'] = actions.select_horizontal,
              ['<c-e>'] = layout_actions.toggle_preview,
              ['<c-l>'] = layout_actions.cycle_layout_next,
              ['<c-r>'] = actions.to_fuzzy_refine,
              ['<Tab>'] = actions.toggle_selection,
              ['<CR>'] = actions.select_default,
              ['<C-o>'] = open_media_files,
            },
          },
        },
        pickers = {
          registers = cursor(),
          reloader = dropdown(),
          git_branches = dropdown(),
          oldfiles = dropdown({ previewer = false }),
          spell_suggest = dropdown({ previewer = false }),
          find_files = { hidden = true },
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
            db_root = join_paths(data, 'databases'),
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
            open_buffer_indicators = { previous = '👀', others = '🙈' },
          },
        },
      })

      local l = require('telescope').load_extension
      if rvim.is_available('text-case.nvim') then l('textcase') end
      if rvim.is_available('harpoon') then l('harpoon') end
      if rvim.is_available('nvim-notify') then l('notify') end
      if rvim.is_available('persisted.nvim') then l('persisted') end
      if rvim.is_available('project.nvim') then l('projects') end

      api.nvim_exec_autocmds(
        'User',
        { pattern = 'TelescopeConfigComplete', modeline = false }
      )
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'aznhe21/actions-preview.nvim',
        cond = rvim.lsp.enable and false,
        opts = { telescope = rvim.telescope.vertical() },
      },
    },
  },
  {
    'biozz/whop.nvim',
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
    'nvim-telescope/telescope-frecency.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('frecency') end,
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
    'molecule-man/telescope-menufacture',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('menufacture') end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('file_browser') end,
  },
  {
    -- 'piersolenski/telescope-import.nvim',
    'razak17/telescope-import.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('import') end,
  },
  {
    'catgoose/telescope-helpgrep.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('helpgrep') end,
  },
  {
    -- 'tsakirist/telescope-lazy.nvim',
    'razak17/telescope-lazy.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('lazy') end,
  },
  {
    'fbuchlak/telescope-directory.nvim',
    cmd = 'Telescope',
    config = function() require('telescope').load_extension('directory') end,
    opts = {},
  },
}
