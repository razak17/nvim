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
  open = function(source, opts)
    opts = opts or {}
    opts.layout = vim.tbl_extend('keep', opts.layout or {}, {
      preview = ar.config.picker.win.show_preview,
    })
    return Snacks.picker.pick(source, opts)
  end,
}
if ar.config.picker.variant == 'snacks' then ar.pick.register(picker_config) end

local api, fn = vim.api, vim.fn
local fmt = string.format
local border_style = vim.o.winborder
local diag_icons = ar.ui.codicons.lsp
local show_preview = ar.config.picker.win.show_preview

---@param source string
---@param opts? snacks.picker.proc.Config
---@return function
local function p(source, opts)
  opts = opts or {}
  if source == 'files' then
    opts.layout = vim.tbl_extend('keep', opts.layout or {}, {
      preview = show_preview,
      cycle = true,
    })
  end
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
    layout = { preview = 'main', cycle = true, preset = 'my_select' },
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
  local text = fn.getreg('v')
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
    layout = { preview = 'main', preset = 'my_select' },
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
    cmd = 'fd',
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
    args = { '--glob', '*.md', '--sortr=modified' },
  })()
end

-- https://github.com/chrisgrieser/.config/blob/fa7a24dc15cc5061f2061a54c509076103e7c419/nvim/lua/plugin-specs/snacks-picker.lua?plain=1#L6
-- lightweight version of `telescope-import.nvim`
local function imports()
  p('grep_word', {
    title = 'Imports',
    cmd = 'rg',
    args = { '--only-matching' },
    live = false,
    regex = true,
    search = [[local (\w+) ?= ?require\(["'](.*?)["']\)(\.[\w.]*)?]],
    ft = 'lua',
    layout = { preset = 'small_no_preview' },
    transform = function(item, ctx) -- ensure items are unique
      ctx.meta.done = ctx.meta.done or {}
      local import = item.text:gsub('.-:', '') -- different occurrences of same import
      if ctx.meta.done[import] then return false end
      ctx.meta.done[import] = true
    end,
    format = function(item, _picker) -- only display the grepped line
      local out = {}
      local line = item.line:gsub('^local ', '')
      Snacks.picker.highlight.format(item, line, out)
      return out
    end,
    confirm = function(picker, item) -- insert the line below the current one
      picker:close()
      vim.cmd.normal({ 'o', bang = true })
      api.nvim_set_current_line(item.line)
      vim.cmd.normal({ '==l', bang = true })
    end,
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
    desc = 'snacks picker',
    recommended = true,
    'folke/snacks.nvim',
    init = function()
      if ar.config.picker.variant == 'snacks' then
        local function fuzzy_in_cur_dir(source, recursive)
          return function()
            local current_file = api.nvim_buf_get_name(0)
            local current_dir = fn.fnamemodify(current_file, ':h')
            local args = {}
            if recursive and source == 'files' then
              args = recursive and { '--files', current_dir }
                or { '--max-depth', '1', '--files', current_dir }
            end
            p(source, {
              title = fmt(
                '%s In Dir%s',
                source == 'files' and 'Find Files' or source == 'Live Grep',
                recursive and ' & Children' or ''
              ),
              cwd = current_dir,
              cmd = source == 'files' and 'rg' or 'rg',
              args = args,
            })()
          end
        end

        ar.add_to_select_menu('command_palette', {
          ['Find Files In Dir'] = fuzzy_in_cur_dir('files', false),
          ['Find Files In Dir & Children'] = fuzzy_in_cur_dir('files', true),
          ['Live Grep In Dir'] = fuzzy_in_cur_dir('grep'),
          ['Find Word In Dir'] = fuzzy_in_cur_dir('grep_word'),
        })
      end
    end,
    keys = function(_, keys)
      keys = keys or {}
      if ar.config.picker.files == 'snacks' then
        table.insert(keys, { '<C-p>', find_files, desc = 'snacks: find files' })
      end
      if ar.config.buffers.variant == 'snacks' then
        table.insert(keys, { '<M-space>', buffers, desc = 'snacks: buffers' })
      end
      if ar.config.picker.variant == 'snacks' then
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
          { '<leader>fi', imports, desc = 'imports' },
          { '<leader>fI', p('pickers'), desc = 'availble pickers' },
          { '<leader>fk', p('keymaps'), desc = 'keymaps' },
          { '<leader>fK', p('colorschemes'), desc = 'colorschemes' },
          { '<leader>fla', lazy, desc = 'all plugins' },
          { '<leader>flL', p('lsp_config'), desc = 'lsp servers' },
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
          { '<leader>fqq', p('qflist'), desc = 'quickfix list' },
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
        if ar.config.explorer.variant == 'snacks' then
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
          if ar.config.lsp.symbols.enable and ar.config.lsp.symbols.variant == 'picker' then
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
            small_no_preview = {
              layout = {
                box = 'horizontal',
                height = ar.config.picker.win.fullscreen and 50 or 0.65,
                width = ar.config.picker.win.fullscreen and 400 or 0.6,
                border = 'none',
                {
                  box = 'vertical',
                  border = border_style,
                  title = '{title} {live} {flags}',
                  { win = 'input', height = 1, border = 'bottom' },
                  { win = 'list', border = 'none' },
                },
              },
            },
            very_vertical = {
              preset = 'small_no_preview',
              layout = { height = 0.95, width = 0.45 },
            },
            wide_with_preview = {
              preset = 'small_no_preview',
              layout = {
                -- width = 0.99,
                height = ar.config.picker.win.fullscreen and 50 or 0.75,
                width = ar.config.picker.win.fullscreen and 400 or 0.9,
                [2] = { -- as second column
                  win = 'preview',
                  title = '{preview}',
                  border = border_style,
                  width = 0.5,
                  wo = { number = false, statuscolumn = ' ', signcolumn = 'no' },
                },
              },
            },
            large_with_preview = {
              preset = 'wide_with_preview',
              layout = {
                height = ar.config.picker.win.fullscreen and 50 or 0.9,
                width = ar.config.picker.win.fullscreen and 400 or 0.9,
                [2] = { width = 0.6 }, -- second win is the preview
              },
            },
            big_preview = {
              preset = 'wide_with_preview',
              layout = {
                height = ar.config.picker.win.fullscreen and 50 or 0.85,
                [2] = { width = 0.6 }, -- second win is the preview
              },
            },
            toggled_preview = {
              preset = 'big_preview',
              preview = false,
            },
            my_telescope = {
              reverse = false,
              layout = {
                box = 'horizontal',
                backdrop = false,
                height = ar.config.picker.win.fullscreen and 50 or 0.9,
                width = ar.config.picker.win.fullscreen and 400 or 0.9,
                border = 'none',
                {
                  box = 'vertical',
                  {
                    win = 'input',
                    height = 1,
                    border = border_style,
                    title = '{title} {live} {flags}',
                    title_pos = 'center',
                  },
                  {
                    win = 'list',
                    title = ' Results ',
                    title_pos = 'center',
                    border = border_style,
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
            my_select = {
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
                {
                  win = 'preview',
                  title = '{preview}',
                  height = 0.4,
                  border = 'top',
                },
              },
            },
            right_sidebar = {
              preset = 'sidebar',
              layout = { position = 'right' },
            },
          },
          prompt = fmt('%s ', ar.ui.icons.misc.chevron_right),
          sources = {
            buffers = { layout = { preset = 'my_select' } },
            colorschemes = { layout = { max_height = 8, preset = 'ivy' } },
            explorer = {
              hidden = true,
              auto_close = true,
              layout = { preset = 'very_vertical' }, -- right_sidebar
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
                    ['d'] = 'explorer_del',
                    ['h'] = 'explorer_close', -- go up folder
                    ['l'] = 'confirm', -- enter folder / open file
                    ['O'] = { { 'pick_win', 'jump' }, mode = { 'n', 'i' } },
                    ['w'] = 'window_picker',
                    ['y'] = 'explorer_copy',
                    ['z'] = 'explorer_close_all',
                    ['-'] = 'focus_input', -- i.e. search
                    ['.'] = 'toggle_hidden_and_ignored',
                    [']c'] = 'explorer_git_next',
                    ['[c'] = 'explorer_git_prev',
                    ['<C-b>'] = 'close',
                    ['<C-g>'] = 'grep_files_in_dir',
                    ['<C-p>'] = 'find_files_in_dir',
                  },
                },
              },
            },
            files = {
              cmd = 'rg',
              args = {
                '--files', -- turn `rg` into a file finder
                '--sortr=modified', -- sort by recency, slight performance impact
                '--no-config',
              },
              hidden = true,
              ignored = true,
              matcher = { frecency = true }, -- slight performance impact
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
                '.output',
                'vim-sessions',
                '.vercel',
                '.netlify',
                'lcov-report',
                '__snapshots__',
                'lazy-lock.json',
                'package-lock.json',
                'pnpm-lock.yaml',
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
              },
              win = {
                input = {
                  keys = {
                    ['<C-h>'] = { 'toggle_hidden_and_ignored', mode = 'i' }, -- consistent with `fzf`
                    [':'] = { 'complete_and_add_colon', mode = 'i' },
                  },
                },
              },
              -- if binary, open in system application instead
              confirm = function(picker, item, action)
                local abs_path = Snacks.picker.util.path(item) or ''
                local binary_ext = { 'pdf', 'png', 'webp', 'docx' }
                local ext = abs_path:match('.+%.([^.]+)$') or ''
                if vim.tbl_contains(binary_ext, ext) then
                  vim.ui.open(abs_path)
                  picker:close()
                  return
                end
                Snacks.picker.actions.confirm(picker, item, action)
              end,
              actions = {
                complete_and_add_colon = function(picker)
                  -- snacks allows opening files with `file:lnum`, but it
                  -- only matches if the filename is complete. With this
                  -- action, we complete the filename if using the 1st colon
                  -- in the query.
                  local query = api.nvim_get_current_line()
                  local file = picker:current().file
                  if not file or query:find(':') then
                    fn.feedkeys(':', 'n')
                    return
                  end
                  api.nvim_set_current_line(file .. ':')
                  vim.cmd.startinsert({ bang = true })
                end,
              },
            },
            gh_issue = { layout = 'big_preview' },
            gh_pr = { layout = 'big_preview' },
            git_branches = { all = true }, -- = include remotes
            git_diff = {
              layout = 'big_preview',
              win = {
                input = {
                  keys = {
                    ['<Tab>'] = { 'list_down_wrapping', mode = 'i' },
                    ['<Space>'] = { 'git_stage', mode = 'i' },
                    -- <CR> opens the file as usual
                  },
                },
              },
            },
            git_log = { layout = 'toggled_preview' },
            git_log_file = { layout = 'toggled_preview' },
            git_status = {
              layout = 'big_preview',
              win = {
                input = {
                  keys = {
                    ['<Tab>'] = { 'list_down_wrapping', mode = 'i' },
                    ['<Space>'] = { 'git_stage', mode = 'i' },
                    -- <CR> opens the file as usual
                  },
                },
              },
            },
            grep = {
              cmd = 'rg',
              args = {
                '--sortr=modified', -- sort by recency, slight performance impact
              },
              regex = false, -- use fixed strings by default
              hidden = true,
              ignored = true,
              win = {
                input = {
                  keys = {
                    ['<C-h>'] = { 'toggle_hidden_and_ignored', mode = 'i' }, -- consistent with `fzf`
                    ['<C-r>'] = { 'toggle_regex', mode = 'i' },
                  },
                },
              },
              exclude = {
                'tags',
                'node_modules',
                '.git',
                'dist',
                'build',
                '.next',
                '.output',
                'package-lock.json',
                'pnpm-lock.yaml',
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
            grep_word = {
              exclude = {
                'tags',
                'node_modules',
                '.git',
                'dist',
                'build',
                '.next',
                '.output',
                'package-lock.json',
                'pnpm-lock.yaml',
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
            help = {
              confirm = function(picker)
                picker:action('help')
                vim.cmd.only() -- so help is full window
              end,
            },
            highlights = {
              confirm = function(picker, item)
                fn.setreg('+', item.hl_group)
                vim.notify(
                  item.hl_group,
                  nil,
                  { title = 'Copied', icon = '󰅍' }
                )
                picker:close()
              end,
            },
            icons = {
              layout = {
                preset = 'small_no_preview',
                layout = { width = 0.7 },
              },
              matcher = { frecency = true }, -- slight performance impact
              -- PENDING https://github.com/folke/snacks.nvim/pull/2520
              confirm = function(picker, item, action)
                picker:close()
                if not item then return end
                local value = item[action.field] or item.data or item.text
                vim.api.nvim_paste(value, true, -1)
                if picker.input.mode ~= 'i' then return end
                vim.schedule(function()
                  -- `nvim_paste` puts the cursor on the last character, so we need to
                  -- emulate `a` to re-enter insert mode at the correct position. However,
                  -- `:startinsert` does `i` and `:startinsert!` does `A`, so we need to
                  -- check if the cursor is at the end of the line.
                  local col = vim.fn.virtcol('.')
                  local eol = vim.fn.virtcol('$') - 1
                  if col == eol then
                    vim.cmd.startinsert({ bang = true })
                  else
                    vim.cmd.normal({ 'l', bang = true })
                    vim.cmd.startinsert()
                  end
                end)
              end,
            },
            keymaps = {
              -- open keymap definition
              confirm = function(picker, item)
                if not item.file then return end
                picker:close()
                local lnum = item.pos[1]
                vim.cmd(('edit +%d %s'):format(lnum, item.file))
              end,
              layout = 'toggled_preview',
            },
            lsp_definitions = { layout = { preview = 'main', preset = 'ivy' } },
            lsp_references = { layout = { preview = 'main', preset = 'ivy' } },
            lsp_config = {
              layout = 'big_preview',
              confirm = function(picker, item)
                if not item.enabled then
                  vim.notify('LSP server not enabled', vim.log.levels.WARN)
                  return
                end
                picker:close()

                vim.schedule(
                  function() -- scheduling needed for treesitter folding
                    local client = item.attached
                        and vim.lsp.get_clients({ name = item.name })[1]
                      or vim.lsp.config[item.name]
                    local type = item.attached and 'running' or 'enabled'
                    Snacks.win({
                      title = (' 󱈄 %s (%s) '):format(item.name, type),
                      text = vim.inspect(client),
                      width = 0.9,
                      height = 0.9,
                      border = border_style,
                      bo = { ft = 'lua' }, -- `.bo.ft` instead of `.ft` needed for treesitter folding
                      wo = {
                        statuscolumn = ' ', -- adds padding
                        cursorline = true,
                        winfixbuf = true,
                        fillchars = 'fold: ,eob: ',
                        foldmethod = 'expr',
                        foldexpr = 'v:lua.vim.treesitter.foldexpr()',
                      },
                    })
                  end
                )
              end,
            },
            recent = {
              layout = { preset = 'small_no_preview' },
              filter = {
                filter = function(item)
                  return vim.fs.basename(item.file) ~= 'COMMIT_EDITMSG'
                end,
              },
            },
            registers = {
              transform = function(item) return item.label:find('[1-9]') ~= nil end, -- only numbered
              confirm = {
                action = { 'yank', 'close' },
                source = 'registers',
                notify = false,
              },
            },
            select = {
              layout = { preview = false, preset = 'my_select' },
            },
          },
          debug = { scores = false },
          formatters = {
            file = { filename_first = true, truncate = 80 },
          },
          layout = { cycle = true, preset = 'large_with_preview' },
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
            toggle_hidden_and_ignored = function(picker)
              picker.opts['hidden'] = not picker.opts.hidden
              picker.opts['ignored'] = not picker.opts.ignored

              if picker.opts.finder ~= 'explorer' then
                -- remove `--ignore-file` extra arg
                picker.opts['_originalArgs'] = picker.opts['_originalArgs']
                  or picker.opts.args
                local noIgnoreFileArgs = vim
                  .iter(picker.opts.args)
                  :filter(
                    function(arg)
                      return not vim.startswith(arg, '--ignore-file=')
                    end
                  )
                  :totable()
                picker.opts['args'] = picker.opts.hidden and noIgnoreFileArgs
                  or picker.opts['_originalArgs']
              end

              picker:find()
            end,
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
  {
    'razak17/todo-comments.nvim',
    optional = true,
    opts = function()
      if ar.config.picker.variant == 'snacks' then
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
}
