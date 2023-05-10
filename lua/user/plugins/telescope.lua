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
  return require('telescope.themes').get_cursor(vim.tbl_extend('keep', opts or {}, {
    layout_config = { width = 0.4, height = fit_to_available_height },
    borderchars = border.ui_select,
  }))
end

rvim.telescope = {
  cursor = cursor,
  dropdown = dropdown,
  adaptive_dropdown = function(_) return dropdown({ height = fit_to_available_height }) end,
  minimal_ui = function(_) return dropdown({ previewer = false }) end,
}

local function extensions(name) return require('telescope').extensions[name] end

local function delta_opts(opts, is_buf)
  local previewers = require('telescope.previewers')
  local delta = previewers.new_termopen_previewer({
    get_command = function(entry)
      -- stylua: ignore
      local args = {
        'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!',
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
local function find_files(opts) return extensions('menufacture').find_files(opts) end
local function git_files(opts) return extensions('menufacture').git_files(opts) end

local function nvim_config()
  find_files({
    prompt_title = '~ rVim config ~',
    cwd = vim.fn.stdpath('config'),
    file_ignore_patterns = { '.git/.*', 'dotbot/.*', 'zsh/plugins/.*' },
  })
end

local function project_files()
  if not pcall(git_files, { show_untracked = true }) then find_files() end
end

local function frecency() extensions('frecency').frecency(dropdown(rvim.telescope.minimal_ui())) end
local function luasnips() extensions('luasnip').luasnip(dropdown()) end
local function notifications() extensions('notify').notify(dropdown()) end
local function undo() extensions('undo').undo() end
local function projects() extensions('projects').projects({}) end

local function builtin() return require('telescope.builtin') end

local function delta_git_commits(opts) builtin().git_commits(delta_opts(opts)) end
local function delta_git_bcommits(opts) builtin().git_bcommits(delta_opts(opts, true)) end

---@param opts? table
---@return function
local function b(picker, opts)
  opts = opts or {}
  return function() require('telescope.builtin')[picker](opts) end
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
  if not num_selections or num_selections <= 1 then actions.add_selection(prompt_bufnr) end
  actions.send_selected_to_qflist(prompt_bufnr)
  vim.cmd('cfdo ' .. open_cmd)
end

local function multi_selection_open(prompt_bufnr) multiopen(prompt_bufnr, 'edit') end

return {
  'nvim-telescope/telescope.nvim',
  keys = {
    { '<c-p>', find_files, desc = 'find files' },
    { '<leader>f?', b('help_tags'), desc = 'help tags' },
    { '<leader>fa', b('builtin', { include_extensions = true }), desc = 'builtins' },
    { '<leader>fb', b('current_buffer_fuzzy_find'), desc = 'find in current buffer' },
    { '<leader>fc', nvim_config, desc = 'nvim config' },
    { '<leader>ff', project_files, desc = 'project files' },
    { '<leader>fh', frecency, desc = 'Most (f)recently used files' },
    { '<leader>fL', luasnips, desc = 'luasnip: available snippets' },
    { '<leader>fn', notifications, desc = 'notify: notifications' },
    { '<leader>fo', b('buffers'), desc = 'buffers' },
    { '<leader>fp', projects, desc = 'projects' },
    { '<leader>fr', b('resume'), desc = 'resume last picker' },
    { '<leader>fs', live_grep, desc = 'find string' },
    { '<leader>fu', undo, desc = 'undo' },
    { '<leader>fw', b('grep_string'), desc = 'find word' },
    { '<leader>fva', b('autocommands'), desc = 'autocommands' },
    { '<leader>fvh', b('highlights'), desc = 'highlights' },
    { '<leader>fvk', b('keymaps'), desc = 'autocommands' },
    { '<leader>fvo', b('vim_options'), desc = 'vim options' },
    { '<leader>fvo', b('registers'), desc = 'registers' },
    -- Git
    { '<leader>gs', b('git_status'), desc = 'git status' },
    { '<leader>fgb', b('git_branches'), desc = 'git branches' },
    { '<leader>fgB', delta_git_bcommits, desc = 'buffer commits' },
    { '<leader>fgc', delta_git_commits, desc = 'commits' },
    -- LSP
    { '<leader>ld', b('lsp_document_symbols'), desc = 'telescope: document symbols' },
    { '<leader>ls', b('lsp_dynamic_workspace_symbols'), desc = 'telescope: workspace symbols' },
    { '<leader>le', b('diagnostics', { bufnr = 0 }), desc = 'telescope: document diagnostics' },
    { '<leader>lw', b('diagnostics'), desc = 'telescope: workspace diagnostics' },
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
        selection_caret = fmt(' %s ', ui.codicons.misc.pick),
        cycle_layout_list = { 'flex', 'horizontal', 'vertical', 'bottom_pane', 'center' },
        sorting_strategy = 'ascending',
        layout_strategy = 'flex',
        set_env = { ['TERM'] = vim.env.TERM },
        borderchars = border.common,
        file_browser = { hidden = true },
        color_devicons = true,
        dynamic_preview_title = true,
        layout_config = { horizontal = { preview_width = 0.55 } },
        winblend = 0,
        history = {
          path = join_paths(data, 'databases', 'telescope_history.sqlite3'),
        },
        -- stylua: ignore
        file_ignore_patterns = {
          '%.jpg', '%.jpeg', '%.png', '%.otf', '%.ttf', '%.DS_Store', '^.git/', 'node%_modules/.*',
          '^dist/', '^build/',  '^site-packages/', '%.yarn/.*',
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
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<c-s>'] = actions.select_horizontal,
            ['<c-e>'] = layout_actions.toggle_preview,
            ['<c-l>'] = layout_actions.cycle_layout_next,
            ['<C-a>'] = multi_selection_open,
            ['<c-r>'] = actions.to_fuzzy_refine,
            ['<Tab>'] = actions.toggle_selection,
            ['<CR>'] = stopinsert(actions.select_default),
          },
          n = {
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<C-a>'] = multi_selection_open,
          },
        },
      },
      pickers = {
        registers = cursor(),
        reloader = dropdown(),
        oldfiles = dropdown(),
        git_branches = dropdown(),
        find_files = { hidden = true },
        colorscheme = { enable_preview = true },
        keymaps = dropdown({ layout_config = { height = 18, width = 0.5 } }),
        git_commits = { layout_config = { horizontal = { preview_width = 0.55 } } },
        git_bcommits = { layout_config = { horizontal = { preview_width = 0.55 } } },
        current_buffer_fuzzy_find = dropdown({ previewer = false, shorten_path = false }),
        diagnostics = themes.get_ivy({ wrap_results = true, borderchars = { preview = border.ivy } }),
        buffers = dropdown({
          sort_mru = true,
          sort_lastused = true,
          show_all_buffers = true,
          ignore_current_buffer = true,
          previewer = false,
          mappings = { i = { ['<c-x>'] = 'delete_buffer' }, n = { ['<c-x>'] = 'delete_buffer' } },
        }),
        live_grep = themes.get_ivy({
          borderchars = { preview = border.ivy },
          file_ignore_patterns = { '.git/', '%.svg', '%.lock', '%-lock.yaml', 'node_modules', '%-lock.json' },
          max_results = 2000,
          additional_args = { '--trim' },
        }),
      },
      extensions = {
        persisted = dropdown(),
        frecency = {
          db_root = join_paths(data, 'databases'),
          default_workspace = 'CWD',
          show_unindexed = false, -- Show all files or only those that have been indexed
          ignore_patterns = { '*.git/*', '*/tmp/*', '*node_modules/*', '*vendor/*' },
          workspaces = { conf = vim.env.DOTFILES, project = vim.g.projects_dir },
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
      },
    })

    require('telescope').load_extension('zf-native')
    require('telescope').load_extension('frecency')
    require('telescope').load_extension('undo')
    require('telescope').load_extension('menufacture')
    require('telescope').load_extension('persisted')
    require('telescope').load_extension('notify')

    vim.api.nvim_exec_autocmds('User', { pattern = 'TelescopeConfigComplete', modeline = false })
  end,
  dependencies = {
    'natecraddock/telescope-zf-native.nvim',
    'nvim-telescope/telescope-frecency.nvim',
    'debugloop/telescope-undo.nvim',
    'molecule-man/telescope-menufacture',
  },
}
