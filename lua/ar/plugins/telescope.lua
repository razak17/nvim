---@type ArPick
local picker_config = {
  name = 'telescope',
  commands = {
    files = 'find_files',
    diagnostics_buffer = 'diagnostics',
  },
  -- this will return a function that calls telescope.
  -- cwd will default to lazyvim.util.get_root
  -- for `files`, git_files or find_files will be chosen depending on .git
  ---@param command string
  ---@param opts? ArPickOpts
  open = function(command, opts)
    opts = opts or {}
    opts.follow = opts.follow ~= false
    if opts.cwd and opts.cwd ~= vim.uv.cwd() then
      local function open_cwd_dir()
        local action_state = require('telescope.actions.state')
        local line = action_state.get_current_line()
        ar.pick.open(
          command,
          vim.tbl_deep_extend('force', {}, opts or {}, {
            root = false,
            default_text = line,
          })
        )
      end
      ---@diagnostic disable-next-line: inject-field
      opts.attach_mappings = function(_, map)
        -- opts.desc is overridden by telescope, until it's changed there is this fix
        map('i', '<a-c>', open_cwd_dir, { desc = 'open cwd directory' })
        return true
      end
    end

    if command == 'diagnostics' then
      opts = vim.tbl_deep_extend('force', {}, opts or {}, {
        bufnr = 0,
        ignore_filename = true,
        layout_strategy = 'center',
      })
    end

    if command == 'files' or command == 'live_grep' then
      opts = vim.tbl_deep_extend('force', {}, opts or {}, { hidden = true })
    end

    if opts.extension then
      local extension = opts.extension
      require('telescope').extensions[extension][command](opts)
    else
      require('telescope.builtin')[command](opts)
    end
  end,
}
if ar_config.picker.variant == 'telescope' then
  ar.pick.register(picker_config)
end

ar.telescope = {}

vim.g.telescope_add_extension = function(extension, opts, config)
  ar.telescope.extensions =
    vim.list_extend(ar.telescope.extensions or {}, extension)
  if config then
    opts.extensions = vim.tbl_extend('force', opts.extensions or {}, config)
  end
  return opts
end

local api, env, fn = vim.api, vim.env, vim.fn
local fmt, ui = string.format, ar.ui
local border = ui.border
local datapath = vim.fn.stdpath('data')
local minimal = ar.plugins.minimal
local enabled = not ar.plugin_disabled('telescope.nvim')
local min_enabled = enabled and not minimal
local is_telescope = ar_config.picker.variant == 'telescope'
local picker_enabled = min_enabled and is_telescope

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
---@return nil | fun(opts: table?): function
local function extensions(name, prop)
  if not picker_enabled then return end
  return function(opts)
    return function(more_opts)
      local o = vim.tbl_extend('force', opts or {}, more_opts or {})
      if not ar.has(extension_to_plugin(name)) then
        vim.notify(fmt('%s is not available.', extension_to_plugin(name)))
        return
      end
      require('telescope').extensions[name][prop or name](o)
    end
  end
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

local function ecolog() extensions('ecolog', 'env')(ar.telescope.minimal_ui())() end
local function luasnips() extensions('luasnip')({})() end
local function notifications() extensions('notify')({})() end
local function projects() extensions('projects')(ar.telescope.minimal_ui())() end
local function aerial() extensions('aerial')({})() end
local function harpoon()
  extensions('harpoon', 'marks')({ prompt_title = 'Harpoon Marks' })()
end
local function textcase()
  extensions('textcase', 'normal_mode')(ar.telescope.minimal_ui())()
end
local function live_grep(opts)
  return extensions('menufacture', 'live_grep')(opts)()
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
---@param prompt_bufnr number
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

---@param prompt_bufnr number
local function open_file_in_centered_popup(prompt_bufnr)
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local file_path = action_state.get_selected_entry().path
  local lines = fn.readfile(file_path)
  local bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  local filetype = fn.fnamemodify(file_path, ':e')
  if filetype ~= '' then
    api.nvim_set_option_value('filetype', filetype, { buf = bufnr })
  end
  actions.close(prompt_bufnr)
  ar.open_buf_centered_popup(bufnr, true)
end

local function open_media_files()
  local action_state = require('telescope.actions.state')
  local file_path = action_state.get_selected_entry().path
  if not file_path then
    vim.notify('No file selected')
    return
  end
  local file_extension = file_path:match('^.+%.(.+)$')
  if vim.list_contains(ar.get_media(), file_extension) then
    ar.open_media(file_path)
  else
    vim.notify('Not a media file')
  end
end

---@param prompt_bufnr number
local function open_with_window_picker(prompt_bufnr)
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local file_path = action_state.get_selected_entry().path
  if not file_path then
    vim.notify('No file selected')
    return
  end
  actions.close(prompt_bufnr)
  vim.defer_fn(function()
    ar.open_with_window_picker(function() vim.cmd('e ' .. file_path) end)
  end, 100)
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
---@param prompt_bufnr number
local focus_preview = function(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt_win = picker.prompt_win
  local previewer = picker.previewer
  local winid = previewer.state.winid
  local bufnr = previewer.state.bufnr
  if not winid then
    vim.notify('No preview window found')
    return
  end
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

---@param prompt_bufnr number
local function send_files_to_grapple(prompt_bufnr)
  if not ar.has('grapple.nvim') then
    vim.notify('grapple.nvim is not available')
    return
  end
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not multi or vim.tbl_isempty(multi) then
    local file_path = action_state.get_selected_entry().path
    require('grapple').toggle({ path = file_path })
  else
    vim.iter(multi):each(function(selection)
      local tag_exists = require('grapple').exists({ path = selection.path })
      if selection.path and not tag_exists then
        require('grapple').toggle({ path = selection.path })
      end
    end)
  end
  actions.close(prompt_bufnr)
end

ar.telescope = vim.tbl_extend('force', ar.telescope, {
  extension_to_plugin = {
    ['aerial'] = 'aerial.nvim',
    ['ecolog'] = 'ecolog.nvim',
    ['fzf'] = 'telescope-fzf-native.nvim',
    ['harpoon'] = 'harpoon',
    ['luasnip'] = 'telescope-luasnip.nvim',
    ['menufacture'] = 'telescope-menufacture',
    ['notify'] = 'nvim-notify',
    ['persisted'] = 'persisted.nvim',
    ['projects'] = 'project.nvim',
    ['textcase'] = 'text-case.nvim',
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
})

return {
  {
    'nvim-telescope/telescope.nvim',
    cond = min_enabled,
    -- NOTE: usind cmd causes issues with dressing and frecency
    cmd = { 'Telescope' },
    event = 'VeryLazy',
    keys = function()
      local mappings = {}

      if ar_config.picker.files == 'telescope' then
        table.insert(mappings, { '<C-p>', find_files, desc = 'find files' })
      end
      if is_telescope then
        -- stylua: ignore
        local telescope_mappings = {
          { '<M-space>', b('buffers'), desc = 'buffers' },
          { '<leader>f?', b('help_tags'), desc = 'help tags' },
          -- { '<leader>fb', b('current_buffer_fuzzy_find'), desc = 'find in current buffer', },
          { '<leader>fc', nvim_config, desc = 'nvim config' },
          { '<leader>fd', aerial, desc = 'aerial' },
          { '<leader>f;', ecolog, desc = 'ecolog' },
          { '<leader>ff', find_files, desc = 'find files' },
          { '<leader>fI', b('builtin'), desc = 'builtins', },
          { '<leader>fJ', b('jumplist'), desc = 'jumplist', },
          { '<leader>fk', b('keymaps'), desc = 'keymaps' },
          { '<leader>fS', luasnips, desc = 'luasnip: available snippets' },
          { '<leader>fn', notifications, desc = 'notify: notifications' },
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
          { '<leader>fm', harpoon, desc = 'harpoon' },
          { '<leader>ft', textcase, desc = 'textcase', mode = { 'n', 'v' } },
          { '<leader>fw', b('grep_string'), desc = 'find word' },
          { '<leader>fva', b('autocommands'), desc = 'autocommands' },
          { '<leader>fvc', b('commands'), desc = 'commands' },
          { '<leader>fvh', b('highlights'), desc = 'highlights' },
          { '<leader>fvo', b('vim_options'), desc = 'vim options' },
          { '<leader>fvr', b('registers'), desc = 'registers' },
          { '<leader>fvk', b('command_history'), desc = 'command history' },
          { '<leader>fK', b('colorscheme'), desc = 'colorscheme' },
          { '<leader>fY', b('spell_suggest'), desc = 'spell suggest' },
        }
        vim
          .iter(telescope_mappings)
          :each(function(m) table.insert(mappings, m) end)
      end

      return mappings
    end,
    opts = function(_, opts)
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
      local previewer_maker = function(filepath, bufnr, o)
        o = o or {}
        o.use_ft_detect = o.use_ft_detect or true
        -- if the file is too large, don't use the ft detect
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, filepath)
        if ok and stats and stats.size > max_filesize then
          o.use_ft_detect = false
        end
        -- if the file is in the ignore list, don't use the ft detect
        vim.iter(ignore_preview):map(function(item)
          if filepath:match(item) then
            o.use_ft_detect = false
            return
          end
        end)
        filepath = fn.expand(filepath)
        previewers.buffer_previewer_maker(filepath, bufnr, o)
      end

      opts = vim.tbl_extend('force', opts or {}, {
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
              ['<C-c>'] = function() vim.cmd.stopinsert() end,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<esc>'] = actions.close,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<C-s>'] = actions.select_horizontal,
              ['<C-e>'] = layout_actions.toggle_preview,
              ['<A-[>'] = layout_actions.cycle_layout_next,
              ['<A-]>'] = layout_actions.cycle_layout_next,
              ['<C-a>'] = multi_selection_open,
              ['<C-r>'] = actions.to_fuzzy_refine,
              ['<Tab>'] = toggle_selection_and_next,
              ['<CR>'] = stopinsert(actions.select_default),
              ['<C-o>'] = open_media_files,
              ['<C-y>'] = open_file_in_centered_popup,
              ['<A-CR>'] = open_with_window_picker,
              ['<C-z>'] = send_files_to_grapple,
              ['<A-q>'] = actions.send_to_loclist + actions.open_loclist,
              ['<C-h>'] = actions.results_scrolling_left,
              ['<C-l>'] = actions.results_scrolling_right,
              ['<A-h>'] = actions.preview_scrolling_left,
              ['<A-l>'] = actions.preview_scrolling_right,
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
              ['<A-u>'] = actions.results_scrolling_up,
              ['<A-d>'] = actions.results_scrolling_down,
              ['<A-j>'] = actions.cycle_history_next,
              ['<A-k>'] = actions.cycle_history_prev,
              ['<C-f>'] = send_find_files_to_live_grep,
              ['<A-;>'] = focus_preview,
            },
            n = {
              ['<C-n>'] = actions.move_selection_next,
              ['<C-p>'] = actions.move_selection_previous,
              ['<M-CR>'] = open_with_window_picker,
            },
          },
          preview = {
            filesize_limit = 1.5, -- MB
          },
        },
        pickers = {
          registers = cursor(),
          reloader = dropdown(),
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
          builtin = { include_extensions = true },
          buffers = dropdown({
            initial_mode = 'normal',
            sort_mru = true,
            select_current = true,
            previewer = false,
            mappings = {
              i = { ['<c-x>'] = 'delete_buffer' },
              n = {
                ['<c-x>'] = 'delete_buffer',
                ['d'] = actions.delete_buffer,
                ['q'] = actions.close,
              },
            },
          }),
          grep_string = {
            file_ignore_patterns = {
              '%.svg',
              '%.lock',
              '%-lock.yaml',
              '%-lock.json',
              '/node_modules/',
              '^node_modules/',
            },
            max_results = 2000,
          },
          live_grep = {
            file_ignore_patterns = {
              '%.svg',
              '%.lock',
              '%-lock.yaml',
              '%-lock.json',
              '/node_modules/',
              '^node_modules/',
            },
            max_results = 2000,
            additional_args = { '--trim' },
          },
        },
      })

      opts.extensions = vim.tbl_extend('force', opts.extensions or {}, {
        fzf = { fuzzy = true },
        persisted = dropdown(),
        menufacture = {
          mappings = { main_menu = { [{ 'i', 'n' }] = '<A-m>' } },
        },
      })

      return opts
    end,
    config = function(_, opts)
      require('telescope').setup(opts)

      local l = require('telescope').load_extension

      if not ar.falsy(ar.telescope.extensions) then
        vim.iter(ar.telescope.extensions):each(function(name)
          if name then l(name) end
        end)
      end

      for name, ext in pairs(ar.telescope.extension_to_plugin) do
        if ar.has(ext) then l(name) end
      end

      api.nvim_exec_autocmds(
        'User',
        { pattern = 'TelescopeConfigComplete', modeline = false }
      )

      ar.augroup('MiniFilesClose', {
        event = 'User',
        pattern = 'TelescopeFindPre',
        command = function()
          if _G.MiniFiles then _G.MiniFiles.close() end
        end,
      })
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = min_enabled,
  },
  { 'molecule-man/telescope-menufacture', cond = picker_enabled },
}
