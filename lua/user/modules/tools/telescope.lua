local ui = rvim.ui
local fmt = string.format

---@param opts table
---@return table
local function dropdown(opts)
  opts = opts or {}
  opts.borderchars = ui.border.ui_select
  return require('telescope.themes').get_dropdown(opts)
end

---@return table
local function minimal_ui()
  return require('telescope.themes').get_dropdown({ previewer = false, theme = 'dropdown' })
end

rvim.telescope = { dropdown = dropdown }

local function extensions(name) return require('telescope').extensions[name] end

local function builtin() return require('telescope.builtin') end

local function builtins() builtin().builtin({ include_extensions = true }) end

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
local function find_files(opts) return extensions('menufacture').find_files(opts) end
local function git_files(opts) return extensions('menufacture').git_files(opts) end

local function nvim_config()
  find_files({
    prompt_title = '~ rVim config ~',
    cwd = rvim.get_config_dir(),
    file_ignore_patterns = { '.git/.*', 'dotbot/.*', 'zsh/plugins/.*' },
  })
end

local function project_files()
  if not pcall(git_files, { show_untracked = true }) then find_files() end
end

local function frecency() extensions('frecency').frecency(dropdown(minimal_ui())) end
local function luasnips() extensions('luasnip').luasnip(dropdown()) end
local function notifications() extensions('notify').notify(dropdown()) end
local function undo() extensions('undo').undo() end
local function projects() extensions('projects').projects({}) end
local function delta_git_commits(opts) builtin().git_commits(delta_opts(opts)) end
local function delta_git_bcommits(opts) builtin().git_bcommits(delta_opts(opts, true)) end

local function cmd(alias, command)
  return vim.api.nvim_create_user_command(alias, command, { nargs = 0 })
end

cmd('WebSearch', function()
  local search = vim.fn.input('Search String: ')
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
            { 'Github', ('https://github.com/search?q=' .. search:gsub(' ', '+')) },
            { 'DuckDuckGo', ('https://html.duckduckgo.com/html?q=' .. search:gsub(' ', '+')) },
            { 'Google Search', ('https://www.google.com/search?q=' .. search:gsub(' ', '+')) },
            {
              'Youtube',
              ('https://www.youtube.com/results?search_query=' .. search:gsub(' ', '+')),
            },
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
  searcher(minimal_ui())
end)

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  config = function()
    local previewers = require('telescope.previewers')
    local sorters = require('telescope.sorters')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local layout_actions = require('telescope.actions.layout')
    local themes = require('telescope.themes')

    rvim.augroup('TelescopePreviews', {
      {
        event = { 'User' },
        pattern = { 'TelescopePreviewerLoaded' },
        command = function(args)
          local bufname = vim.tbl_get(args, 'data', 'bufname')
          local ft = bufname and require('plenary.filetype').detect(bufname) or nil
          vim.opt_local.number = not ft or ui.decorations.get(ft, 'number', 'ft') ~= false
        end,
      },
    })

    -- https://github.com/nvim-telescope/telescope.nvim/issues/1048
    -- https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/telescope/init.lua

    -- Open multiple files at once
    local function multiopen(prompt_bufnr, open_cmd)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local num_selections = #picker:get_multi_selection()
      if not num_selections or num_selections <= 1 then actions.add_selection(prompt_bufnr) end
      actions.send_selected_to_qflist(prompt_bufnr)
      vim.cmd('cfdo ' .. open_cmd)
    end

    local function multi_selection_open(prompt_bufnr) multiopen(prompt_bufnr, 'edit') end

    local function stopinsert(callback)
      return function(prompt_bufnr)
        vim.cmd.stopinsert()
        vim.schedule(function() callback(prompt_bufnr) end)
      end
    end

    require('telescope').setup({
      defaults = {
        prompt_prefix = fmt(' %s  ', ui.icons.misc.search_alt),
        selection_caret = fmt(' %s ', ui.icons.misc.pick),
        cycle_layout_list = { 'flex', 'horizontal', 'vertical', 'bottom_pane', 'center' },
        sorting_strategy = 'ascending',
        layout_strategy = 'horizontal',
        set_env = { ['TERM'] = vim.env.TERM },
        borderchars = ui.border.common,
        file_browser = { hidden = true },
        color_devicons = true,
        dynamic_preview_title = true,
        layout_config = {
          height = 0.9,
          width = 0.9,
          preview_cutoff = 120,
          horizontal = { width_padding = 0.04, height_padding = 0.1, preview_width = 0.6 },
          vertical = { width_padding = 0.05, height_padding = 0.1, preview_height = 0.5 },
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
            ['<C-a>'] = multi_selection_open,
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
        buffers = dropdown({
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
        keymaps = dropdown({
          layout_config = { height = 18, width = 0.5 },
        }),
        live_grep = themes.get_ivy({
          borderchars = {
            preview = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' },
          },
          only_sort_text = true,
          file_ignore_patterns = {
            '.git/',
            '%.html',
            'dotbot/.*',
            'zsh/plugins/.*',
            'yarn.lock',
            'package-lock.json',
          },
          max_results = 2000,
        }),
        registers = dropdown({ layout_config = { height = 25 } }),
        oldfiles = dropdown(),
        current_buffer_fuzzy_find = dropdown({ previewer = false, shorten_path = false }),
        colorscheme = { enable_preview = true },
        git_branches = dropdown(),
        git_bcommits = { layout_config = { horizontal = { preview_width = 0.55 } } },
        git_commits = { layout_config = { horizontal = { preview_width = 0.55 } } },
        reloader = dropdown(),
      },
      extensions = {
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
        menufacture = {
          mappings = {
            main_menu = { [{ 'i', 'n' }] = '<C-;>' },
          },
        },
      },
    })

    require('telescope').load_extension('zf-native')
    require('telescope').load_extension('luasnip')
    require('telescope').load_extension('frecency')
    require('telescope').load_extension('undo')
    require('telescope').load_extension('menufacture')

    vim.api.nvim_exec_autocmds('User', { pattern = 'TelescopeConfigComplete', modeline = false })
  end,
  keys = {
    { '<c-p>', find_files, desc = 'find files' },
    { '<leader>f?', function() builtin().help_tags() end, desc = 'help tags' },
    { '<leader>fa', builtins, desc = 'builtins' },
    {
      '<leader>fb',
      function() builtin().current_buffer_fuzzy_find() end,
      desc = 'find in current buffer',
    },
    { '<leader>fc', nvim_config, desc = 'nvim config' },
    { '<leader>ff', project_files, desc = 'project files' },
    { '<leader>fh', frecency, desc = 'Most (f)recently used files' },
    { '<leader>fl', function() builtin().resume() end, desc = 'resume last picker' },
    { '<leader>fL', luasnips, desc = 'luasnip: available snippets' },
    { '<leader>fn', notifications, desc = 'notify: notifications' },
    { '<leader>fo', function() builtin().buffers() end, desc = 'buffers' },
    { '<leader>fp', projects, desc = 'projects' },
    { '<leader>fs', live_grep, desc = 'find string' },
    { '<leader>fS', '<cmd>WebSearch<CR>', desc = 'web search' },
    { '<leader>fu', undo, desc = 'undo' },
    { '<leader>fw', function() builtin().grep_string() end, desc = 'find word' },
    { '<leader>fva', function() builtin().autocommands() end, desc = 'autocommands' },
    { '<leader>fvh', function() builtin().highlights() end, desc = 'highlights' },
    { '<leader>fvk', function() builtin().keymaps() end, desc = 'keymaps' },
    { '<leader>fvo', function() builtin().vim_options() end, desc = 'options' },
    -- Git
    { '<leader>gs', function() builtin().git_status() end, desc = 'git status' },
    { '<leader>fgb', function() builtin().git_branches() end, desc = 'git branches' },
    { '<leader>fgB', delta_git_bcommits, desc = 'buffer commits' },
    { '<leader>fgc', delta_git_commits, desc = 'commits' },
    -- LSP
    {
      '<leader>ld',
      function() builtin().lsp_document_symbols() end,
      desc = 'telescope: document symbols',
    },
    {
      '<leader>ls',
      function() builtin().lsp_dynamic_workspace_symbols() end,
      desc = 'telescope: workspace symbols',
    },
    {
      '<leader>le',
      '<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<CR>',
      desc = 'telescope: document diagnostics',
    },
    {
      '<leader>lw',
      '<cmd>Telescope diagnostics theme=get_ivy<CR>',
      desc = 'telescope: workspace diagnostics',
    },
  },
  dependencies = {
    'natecraddock/telescope-zf-native.nvim',
    'benfowler/telescope-luasnip.nvim',
    'nvim-telescope/telescope-frecency.nvim',
    'debugloop/telescope-undo.nvim',
    'molecule-man/telescope-menufacture',
  },
}
