---@module 'snacks'

---@type ArPick
local picker_config = {
  name = 'snacks',
  commands = {
    files = 'files',
    live_grep = 'grep',
    oldfiles = 'recent',
  },

  ---@param source string
  ---@param opts? snacks.picker.Config
  open = function(source, opts) return Snacks.picker.pick(source, opts) end,
}
if ar_config.picker.variant == 'snacks' then ar.pick.register(picker_config) end

local fn = vim.fn
local fmt = string.format
local border_style = ar_config.ui.border
local diag_icons = ar.ui.codicons.lsp
local show_preview = ar_config.picker.win.show_preview

local picker_layouts = {
  telescope = {
    reverse = false,
    layout = {
      box = 'horizontal',
      backdrop = false,
      height = ar_config.picker.win.fullscreen and 100 or 0.9,
      width = ar_config.picker.win.fullscreen and 400 or 0.9,
      border = 'none',
      {
        box = 'vertical',
        {
          win = 'list',
          title = ' Results ',
          title_pos = 'center',
          border = border_style,
        },
        {
          win = 'input',
          height = 1,
          border = border_style,
          title = '{title} {live} {flags}',
          title_pos = 'center',
        },
      },
      {
        win = 'preview',
        title = '{preview:Preview}',
        width = 0.6,
        border = border_style,
        title_pos = 'center',
      },
    },
  },
  default = {
    layout = {
      box = 'horizontal',
      width = 0.8,
      min_width = 120,
      height = 0.8,
      {
        box = 'vertical',
        border = border_style,
        title = '{title} {live} {flags}',
        { win = 'input', height = 1, border = 'bottom' },
        { win = 'list', border = 'none' },
      },
      {
        win = 'preview',
        title = '{preview}',
        border = border_style,
        width = 0.6,
      },
    },
  },
  select = {
    layout = {
      backdrop = false,
      width = 0.5,
      min_width = 80,
      height = 0.4,
      min_height = 3,
      box = 'vertical',
      border = border_style,
      title = '{title}',
      title_pos = 'center',
      { win = 'input', height = 1, border = 'bottom' },
      { win = 'list', border = 'none' },
      { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
    },
  },
}

---@param source string
---@param opts? snacks.picker.proc.Config
---@return function
local function p(source, opts)
  opts = opts or {}
  opts.layout = vim.tbl_extend('keep', opts.layout or {}, {
    preview = show_preview,
    cycle = true,
  })
  return function() Snacks.picker[source](opts) end
end

local function find_files()
  p('files', {
    matcher = {
      cwd_bonus = true, -- boost cwd matches
      frecency = true, -- use frecency boosting
      sort_empty = true, -- sort even when the filter is empty
    },
    finder = 'files',
    format = 'file',
    show_empty = true,
    supports_live = true,
    layout = { preview = 'main', cycle = true, preset = 'custom_select' },
  })()
end

local function grep_string()
  p('grep', {
    layout = { preview = 'main', cycle = true, preset = 'ivy' },
  })()
end

local function visual_grep_string()
  -- Get visual selection
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  p('grep', {
    layout = { preview = 'main', cycle = true, preset = 'ivy' },
    search = text,
  })()
end

local function grep_word()
  p('grep_word', {
    layout = { preview = 'main', cycle = true, preset = 'ivy' },
  })()
end

local function buffers()
  p('buffers', {
    on_show = function() vim.cmd.stopinsert() end,
    current = true,
    finder = 'buffers',
    format = 'buffer',
    hidden = false,
    unloaded = true,
    sort_lastused = true,
    layout = { preview = 'main', preset = 'custom_select' },
    win = {
      input = {
        keys = {
          ['d'] = 'bufdelete',
        },
      },
      list = { keys = { ['d'] = 'bufdelete' } },
    },
  })()
end

local function lazy()
  p('files', {
    matcher = { frecency = true },
    args = { '--exact-depth', '2', '--ignore-case', 'readme.md' },
    cwd = fn.stdpath('data') .. '/lazy',
    -- on_close = function(picker)
    --   vim.cmd.stopinsert()
    --   if not picker then return end
    --   local items = picker:selected({ fallback = true })
    --   if not items or #items == 0 then return end
    --   local item = items[1]
    --   vim.schedule(function()
    --     if item and item.file and item.file:match('^%w+%.nvim') then
    --       local plugin_name = item.file:match('^(%w+%.nvim)')
    --       ar.pick.open('files', { cwd = item.cwd .. '/' .. plugin_name })
    --     else
    --       vim.notify('No valid plugin found in selection')
    --     end
    --   end)
    -- end,
  })()
end

local function notes()
  p('files', {
    matcher = { frecency = true },
    cwd = ar.sync_dir('obsidian'),
    args = { '--glob', '*.md' },
  })()
end

local function window_picker_action(picker, _, action)
  local items = picker:selected({ fallback = true })
  if not items then
    vim.notify('No items selected')
    return
  end
  if items[1] then
    vim.defer_fn(function()
      ar.open_with_window_picker(
        function() Snacks.picker.actions.jump(picker, _, action) end
      )
    end, 100)
  end
end

return {
  {
    'razak17/todo-comments.nvim',
    optional = true,
    opts = function()
      if ar_config.picker.variant == 'snacks' then
        local function todos()
          p('todo_comments', {
            layout = { preview = 'main', preset = 'ivy' },
            title = 'All Todos',
          })()
        end

        local function todos_fixes()
          p('todo_comments', {
            keywords = { 'TODO', 'FIX', 'FIXME' },
            layout = { preview = 'main', preset = 'ivy' },
            title = 'TODO/FIXME Todos',
          })()
        end

        local function config_todos()
          p('todo_comments', {
            keywords = { 'TODO', 'FIX', 'FIXME' },
            layout = { preview = 'main', preset = 'ivy' },
            cwd = fn.stdpath('config'),
            title = 'Config Todos',
          })()
        end

        map('n', '<leader>ft', todos, { desc = 'todo' })
        map('n', '<leader>fF', todos_fixes, { desc = 'todo/fixme' })
        map('n', '<leader>fC', config_todos, { desc = 'config todo/fixme' })
      end
    end,
  },
  {
    desc = 'snacks picker',
    recommended = true,
    'folke/snacks.nvim',
    init = function()
      if ar_config.picker.variant == 'snacks' then
        local function fuzzy_in_cur_dir(source, recursive)
          return function()
            local current_file = vim.api.nvim_buf_get_name(0)
            local current_dir = vim.fn.fnamemodify(current_file, ':h')
            p(source, {
              title = fmt(
                '%s In Dir%s',
                source == 'files' and 'Find Files' or source == 'Live Grep',
                recursive and ' & Children' or ''
              ),
              cwd = current_dir,
              cmd = source == 'files' and 'rg' or 'rg',
              args = recursive and { '--files', current_dir }
                or { '--max-depth', '1', '--files', current_dir },
            })()
          end
        end

        ar.add_to_select_menu('command_palette', {
          ['Find Files In Dir'] = fuzzy_in_cur_dir('files', false),
          ['Find Files In Dir & Children'] = fuzzy_in_cur_dir('files', true),
          ['Live Grep In Dir'] = fuzzy_in_cur_dir('grep', true),
          ['Find Word In Dir'] = fuzzy_in_cur_dir('word', true),
        })
      end
    end,
    keys = function(_, keys)
      keys = keys or {}
      if ar_config.picker.files == 'snacks' then
        table.insert(keys, { '<C-p>', find_files, desc = 'snacks: find files' })
      end
      if ar_config.buffers.variant == 'snacks' then
        table.insert(keys, { '<M-space>', buffers, desc = 'snacks: buffers' })
      end
      if ar_config.picker.variant == 'snacks' then
        -- stylua: ignore
        local picker_mappings = {
          { '<leader>fc', p('files', { cwd = fn.stdpath('config') }), desc = 'find config file' },
          { '<leader>ff', p('files'), desc = 'find files' },
          { '<leader>fgb', p('git_branches'), desc = 'find git branches' },
          { '<leader>fgc', p('git_log'), desc = 'find git commits' },
          { '<leader>fgd', p('git_diff'), desc = 'git diff (hunks)' },
          { '<leader>fgD', p('git_diff', { base = 'origin' }), desc = 'git diff (origin)' },
          { '<leader>fgf', p('git_log_file'), desc = 'git log file' },
          { '<leader>fgF', p('git_grep'), desc = 'git grep' },
          { '<leader>fgg', p('git_files'), desc = 'find git files' },
          { '<leader>fgl', p('git_log'), desc = 'git log' },
          { '<leader>fgL', p('git_log_line'), desc = 'git log line' },
          { '<leader>fgs', p('git_status'), desc = 'git status' },
          { '<leader>fgS', p('git_stash'), desc = 'git stash' },
          { '<leader>fh', p('help'), desc = 'help pages' },
          { '<leader>fI', p('pickers'), desc = 'availble pickers' },
          { '<leader>fk', p('keymaps'), desc = 'keymaps' },
          { '<leader>fK', p('colorschemes'), desc = 'colorschemes' },
          { '<leader>fla', lazy, desc = 'all plugins' },
          { '<leader>fL', p('lines'), desc = 'buffer lines' },
          { '<leader>fm', p('man'), desc = 'man pages' },
          { '<leader>fn', p('notifications'), desc = 'notification history' },
          { '<leader>fo', p('recent'), desc = 'recent' },
          { '<leader>fO', notes, desc = 'notes' },
          { '<leader>fp', p('projects'), desc = 'projects' },
          { '<leader>fP', p('lazy'), desc = 'search for plugin spec' },
          { '<leader>fr', p('resume'), desc = 'resume' },
          { '<leader>fs', grep_string, desc = 'grep' },
          { '<leader>fs', visual_grep_string, desc = 'grep visual selection', mode = 'x' },
          { '<leader>fS', p('grep_buffers'), desc = 'grep open buffers' },
          { '<leader>fql', p('loclist'), desc = 'location list' },
          { '<leader>fqq', p('qflist'), desc = 'quickfix List' },
          { '<leader>fu', p('undo'), desc = 'undo history' },
          { '<leader>fva', p('autocmds'), desc = 'autocmds' },
          { '<leader>fvc', p('commands'), desc = 'commands' },
          { '<leader>fvC', p('command_history'), desc = 'command history' },
          { '<leader>fvh', p('highlights'), desc = 'highlights' },
          { '<leader>fvi', p('icons'), desc = 'icons' },
          { '<leader>fvj', p('jumps'), desc = 'jumps' },
          { '<leader>fvm', p('marks'), desc = 'marks' },
          { '<leader>fvr', p('registers'), desc = 'registers' },
          { '<leader>fvs', p('search_history'), desc = 'search history' },
          { '<leader>fw', grep_word, desc = 'visual selection or word', mode = { 'n', 'x' } },
          -- explorer
          { "<leader>fe", function() Snacks.explorer() end, desc = "explorer" },
        }
        -- stylua: ignore
        if ar_config.explorer.variant == 'snacks' then
          table.insert(picker_mappings, { '<C-n>', function() Snacks.explorer() end, desc = 'explorer' })
        end
        -- stylua: ignore
        if ar.lsp.enable then
          ar.list_insert(picker_mappings, {
            { '<leader>le', p('diagnostics_buffer'), desc = 'snacks: buffer diagnostics' },
            { '<leader>lI', p('lsp_implementations'), desc = 'snacks: goto implementation' },
            { '<leader>lr', p('lsp_references'), nowait = true, desc = 'snacks: references' },
            { '<leader>lw', p('diagnostics'), desc = 'snacks: workspace diagnostics' },
            { '<leader>ly', p('lsp_type_definitions'), desc = 'snacks: goto t[y]pe definition' },
            { 'gai', p('lsp_incoming_calls'), desc = 'c[a]lls incoming' },
            { 'gao', p('lsp_outgoing_calls'), desc = 'c[a]lls outgoing' },
          })
          -- stylua: ignore
          if ar_config.lsp.symbols.enable and ar_config.lsp.symbols.variant == 'picker' then
            ar.list_insert(picker_mappings, {
              { '<leader>lsd', p('lsp_symbols'), desc = 'snacks: lsp symbols' },
              { '<leader>lsw', p('lsp_workspace_symbols'), desc = 'snacks: lsp workspace symbols' },
            })
          end
        end
        vim.iter(picker_mappings):each(function(m) table.insert(keys, m) end)
      end
      return keys
    end,
    opts = function(_, opts)
      return vim.tbl_deep_extend('force', opts or {}, {
        picker = {
          layouts = {
            custom_default = picker_layouts.default,
            custom_telescope = picker_layouts.telescope,
            custom_select = picker_layouts.select,
            sidebar = {
              layout = { layout = { position = 'right' } },
            },
          },
          prompt = fmt(' %s ', ar.ui.icons.misc.chevron_right),
          sources = {
            buffers = {
              layout = { preview = 'main', preset = 'custom_select' },
            },
            lsp_definitions = { layout = { preview = 'main', preset = 'ivy' } },
            lsp_references = { layout = { preview = 'main', preset = 'ivy' } },
            files = {
              hidden = true,
              ignored = true,
              exclude = {
                '.luarc.json',
                'node_modules',
                'env',
                '__pycache__',
                '.mypy_cache',
                '.pytest_cache',
                '.git',
                'tags',
                'dist',
                '.DS_Store',
                'build',
                'tmp',
                'out',
                '.next',
                'vim-sessions',
                '.vercel',
                '.netlify',
                'lcov-report',
                '__snapshots__',
                'lazy-lock.json',
                'package-lock.json',
                'yarn.lock',
                'yarn-error.log',
                'pnpm-lock.yaml',
                'bun.lock',
                'lazyvim.json',
                '.local',
                'share',
                '\\.venv',
                '.coverage',
                '.repro',
                '.nx',
                'package-lock.json',
              },
            },
            grep = {
              hidden = true,
              ignored = true,
              exclude = {
                'tags',
                'node_modules',
                '.git',
                'dist',
                'build',
                '.next',
                'package-lock.json',
                'yarn.lock',
                'yarn-error.log',
                'pnpm-lock.yaml',
                'bun.lock',
                '__snapshots__',
                'lcov-report',
                '.coverage',
                '.nx',
                '\\.venv',
              },
            },
            registers = {
              confirm = {
                action = { 'yank', 'close' },
                source = 'registers',
                notify = false,
              },
            },
            explorer = {
              hidden = true,
              auto_close = false,
              layout = { layout = { position = 'right' } },
              actions = {
                find_files_in_dir = function(_, item, _)
                  vim.defer_fn(
                    ar.pick('files', { cwd = item.parent._path }),
                    200
                  )
                end,
                grep_files_in_dir = function(_, item, _)
                  vim.defer_fn(
                    ar.pick('live_grep', { cwd = item.parent._path }),
                    200
                  )
                end,
                window_picker = function(picker, item, action)
                  if item.dir then return end
                  vim.defer_fn(function()
                    ar.open_with_window_picker(function(picked_window_id)
                      picker.main = picked_window_id
                      Snacks.picker.actions.jump(picker, item, action)
                    end)
                  end, 100)
                end,
              },
              win = {
                list = {
                  keys = {
                    ['z'] = 'explorer_close_all',
                    ['O'] = { { 'pick_win', 'jump' }, mode = { 'n', 'i' } },
                    ['w'] = 'window_picker',
                    [']c'] = 'explorer_git_next',
                    ['[c'] = 'explorer_git_prev',
                    ['<C-b>'] = 'close',
                    ['<C-g>'] = 'grep_files_in_dir',
                    ['<C-p>'] = 'find_files_in_dir',
                  },
                },
              },
            },
          },
          debug = { scores = false },
          formatters = {
            file = { filename_first = true, truncate = 80 },
          },
          layout = {
            cycle = true,
            preset = 'custom_telescope',
          },
          matcher = { frecency = true },
          icons = {
            diagnostics = {
              Error = diag_icons.error .. ' ',
              Warn = diag_icons.warn .. ' ',
              Hint = diag_icons.hint .. ' ',
              Info = diag_icons.info .. ' ',
            },
          },
          actions = {
            trash_files = function(picker, _, _)
              local items = picker:selected({ fallback = true })
              if not items then
                vim.notify('No items selected')
                return
              end
              picker:close()
              if fn.confirm('Delete files?', '&Yes\n&No') == 1 then
                for _, item in ipairs(items) do
                  ar.trash_file(item._path, true)
                end
              end
            end,
            open_with_window_picker = function(picker, _, action)
              picker:close()
              window_picker_action(picker, _, action)
            end,
            parent = {
              action = function(picker, _)
                local cwd = picker:cwd() or vim.uv.cwd()
                cwd = vim.uv.fs_realpath(cwd .. '/..')
                picker:set_cwd(cwd)
                picker:find()
              end,
            },
          },
          win = {
            input = {
              keys = {
                ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
                ['<C-h>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
                ['<A-CR>'] = { 'open_with_window_picker', mode = { 'n', 'i' } },
                ['<A-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
                ['<A-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
                ['<A-h>'] = { 'preview_scroll_left', mode = { 'i', 'n' } },
                ['<A-l>'] = { 'preview_scroll_right', mode = { 'i', 'n' } },
                ['<A-w>'] = { 'cycle_win', mode = { 'i', 'n' } },
                ['<A-BS>'] = { 'parent', mode = { 'i', 'n' } },
                ['<C-w>'] = { 'toggle_help_input', mode = { 'i', 'n' } },
              },
            },
          },
        },
      })
    end,
  },
}
