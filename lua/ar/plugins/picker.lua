---@class FzfLuaOpts: ArPickOpts
---@field cmd string?

---@type ArPick
local picker_config = {
  name = 'fzf',
  commands = {
    files = 'files',
    projects = 'files',
  },

  ---@param command string
  ---@param opts? FzfLuaOpts
  open = function(command, opts)
    opts = opts or {}
    if opts.cmd == nil and command == 'git_files' and opts.show_untracked then
      opts.cmd = 'git ls-files --exclude-standard --cached --others'
    end
    if command == 'files' or command == 'live_grep' then
      opts = vim.tbl_deep_extend('force', {}, opts or {}, { hidden = true })
    end
    return require('fzf-lua')[command](opts)
  end,
}
if ar.config.picker.variant == 'fzf-lua' then
  ar.pick.register(picker_config)
end

local fn, ui, reqcall = vim.fn, ar.ui, ar.reqcall
local fmt = string.format
local icons, codicons, lsp_hls = ui.icons, ui.codicons, ui.lsp.highlights
local prompt = fmt('%s ', icons.misc.chevron_right)
local minimal = ar.plugins.minimal
local border_style = vim.o.winborder

local fzf_lua = reqcall('fzf-lua') ---@module 'fzf-lua'
--------------------------------------------------------------------------------
-- FZF-LUA HELPERS
--------------------------------------------------------------------------------
local find_files = function(cwd) fzf_lua.files({ cwd = cwd }) end

local function dropdown(opts)
  opts = opts or { winopts = {} }
  return vim.tbl_deep_extend('force', {
    prompt = prompt,
    fzf_opts = { ['--layout'] = 'reverse' },
    winopts = {
      title = opts.winopts.title,
      title_pos = opts.winopts.title and 'center' or nil,
      height = 0.70,
      width = 0.45,
      row = 0.1,
      preview = { hidden = 'hidden', layout = 'vertical', vertical = 'up:50%' },
    },
  }, opts)
end

local function cursor_dropdown(opts)
  return dropdown(vim.tbl_deep_extend('force', {
    winopts = { row = 1, relative = 'cursor', height = 0.33, width = 0.25 },
  }, opts))
end

local function list_sessions()
  local fzf = require('fzf-lua')
  local ok, persisted = ar.pcall(require, 'persisted')
  if not ok then return end
  local sessions = persisted.list()
  fzf.fzf_exec(
    vim.tbl_map(function(s) return s.name end, sessions),
    dropdown({
      winopts = { title = '󰆔 Sessions', height = 0.33, row = 0.5 },
      previewer = false,
      actions = {
        ['default'] = function(selected)
          local session = vim
            .iter(sessions)
            :find(function(s) return s.name == selected[1] end)
          if not session then return end
          persisted.load({ session = session.file_path })
        end,
        ['ctrl-d'] = {
          function(selected)
            local session = vim
              .iter(sessions)
              :find(function(s) return s.name == selected[1] end)
            if not session then return end
            fn.delete(vim.fn.expand(session.file_path))
          end,
          fzf.actions.resume,
        },
      },
    })
  )
end

local function lazy()
  fzf_lua.files({
    cwd = fn.stdpath('data') .. '/lazy',
    cmd = 'fd --exact-depth 2 --ignore-case readme.md',
  })
end

local function plugin_spec()
  fzf_lua.files({
    cwd = fn.stdpath('config') .. '/lua/ar/plugins',
  })
end

local function notes()
  fzf_lua.files({
    cwd = ar.sync_dir('obsidian'),
    cmd = "fd --type f --type l --hidden --no-ignore --glob '*.md'",
  })
end

ar.fzf = { dropdown = dropdown, cursor_dropdown = cursor_dropdown }

return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    cond = function()
      if ar.config.picker.variant == 'fzf-lua' then return true end
      if ar.config.picker.files == 'fzf-lua' then return true end
      return ar.get_plugin_cond('fzf-lua', not minimal)
    end,
    init = function()
      vim.g.whichkey_add_spec({
        { '<localleader>f', group = 'Picker' },
        { '<localleader>fg', group = 'Git' },
        { '<localleader>fv', group = 'Vim' },
      })

      if ar.config.picker.variant == 'fzf-lua' then
        local fzf = require('fzf-lua')
        fzf.register_ui_select(function(fzf_opts, items)
          fzf_opts.prompt = fzf_opts.prompt or 'Select one of'

          return vim.tbl_deep_extend('force', fzf_opts, {
            prompt = prompt,
            winopts = {
              title_pos = 'center',
              title = ' '
                .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', ''))
                .. ' ',
              row = 0.5,
            },
          }, fzf_opts.kind == 'codeaction' and {
            winopts = {
              layout = 'vertical',
              -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
              height = math.floor(
                math.min(vim.o.lines * 0.4 - 16, #items + 4) + 0.5
              ) + 16,
              width = 0.5,
              preview = not vim.tbl_isempty(
                    vim.lsp.get_clients({ bufnr = 0, name = 'vtsls' })
                  )
                  and {
                    layout = 'vertical',
                    vertical = 'down:15,border-top',
                    hidden = 'hidden',
                  }
                or {
                  layout = 'vertical',
                  vertical = 'down:15,border-top',
                },
            },
          } or {
            winopts = {
              width = 0.5,
              -- height is number of items, with a max of 80% screen height
              height = math.floor(
                math.min(vim.o.lines * 0.4, #items + 4) + 0.5
              ),
            },
          })
        end)
      end
    end,
    keys = function(_, keys)
      keys = keys or {}
      if ar.config.buffers.variant == 'fzf-lua' then
        table.insert(keys, { '<M-space>', fzf_lua.buffers, desc = 'buffers' })
      end
      if ar.config.picker.variant == 'fzf-lua' then
        -- stylua: ignore
        local fzf_mappings = {
          { '<leader>fa', '<Cmd>FzfLua<CR>', desc = 'builtins' },
          { '<leader>fb', fzf_lua.grep_curbuf, desc = 'current buffer fuzzy find' },
          { '<leader>fc', function() find_files(fn.stdpath('config')) end, desc = 'nvim config' },
          { '<leader>ff', fzf_lua.files, desc = 'find files' },
          { '<leader>fgb', fzf_lua.git_branches, desc = 'branches' },
          { '<leader>fgB', fzf_lua.git_bcommits, desc = 'buffer commits' },
          { '<leader>fgc', fzf_lua.git_commits, desc = 'commits' },
          { '<leader>fgd', fzf_lua.git_diff, desc = 'git diff' },
          { '<leader>fgs', fzf_lua.git_status, desc = 'git status' },
          { '<leader>fgS', fzf_lua.git_stash, desc = 'git stash' },
          { '<leader>fh', fzf_lua.help_tags, desc = 'help tags' },
          { '<leader>fj', fzf_lua.jumps, desc = 'jumplist' },
          { '<leader>fk', fzf_lua.keymaps, desc = 'keymaps' },
          { '<leader>fK', fzf_lua.colorschemes, desc = 'colorschemes' },
          { '<leader>fla', lazy, desc = 'all plugins' },
          { '<leader>fL', fzf_lua.lines, desc = 'lines' },
          { '<leader>fm', fzf_lua.manpages, desc = 'manpages' },
          { '<leader>fM', fzf_lua.changes, desc = 'changes' },
          { '<leader>fo', fzf_lua.oldfiles, desc = 'Most (f)recently used files' },
          { '<leader>fO', notes, desc = 'notes' },
          { '<leader>fp', fzf_lua.global, desc = 'global' },
          { '<leader>fP', plugin_spec, desc = 'search for plugin spec' },
          { '<leader>fr', fzf_lua.resume, desc = 'resume picker' },
          { '<leader>fs', fzf_lua.live_grep, desc = 'live grep' },
          { '<leader>fs', fzf_lua.grep_visual, desc = 'grep visual selection', mode = 'x' },
          { '<leader>fql', fzf_lua.loclist, desc = 'location list' },
          { '<leader>fqq', fzf_lua.quickfix, desc = 'quickfix list' },
          { '<leader>fva', fzf_lua.autocmds, desc = 'autocommands' },
          { '<leader>fvc', fzf_lua.commands, desc = 'commands' },
          { '<leader>fvC', fzf_lua.command_history, desc = 'command history' },
          { '<leader>fvh', fzf_lua.highlights, desc = 'highlights' },
          { '<leader>fvj', fzf_lua.jumps, desc = 'jumps' },
          { '<leader>fvm', fzf_lua.marks, desc = 'marks' },
          { '<leader>fvr', fzf_lua.registers, desc = 'registers' },
          { '<leader>fvs', fzf_lua.search_history, desc = 'search history' },
          { '<leader>fw', fzf_lua.grep_cword, desc = 'grep cword' },
        }
        -- stylua: ignore
        if ar.lsp.enable then
          ar.list_insert(fzf_mappings, {
            { '<leader>le', fzf_lua.diagnostics_document, desc = 'buffer diagnostics' },
            { '<leader>lI', fzf_lua.lsp_implementations, desc = 'search implementation' },
            { '<leader>lr', fzf_lua.lsp_references, desc = 'show references' },
            { '<leader>lw', fzf_lua.diagnostics_workspace, desc = 'workspace diagnostics' },
            { '<leader>ly', fzf_lua.lsp_typedefs, desc = 'type definitions' },
          })
          -- stylua: ignore
          if ar.config.lsp.symbols.enable and ar.config.lsp.symbols.variant == 'picker' then
            ar.list_insert(fzf_mappings, {
              { '<leader>lsd', fzf_lua.lsp_document_symbols, desc = 'document symbols' },
              { '<leader>lsl', fzf_lua.lsp_live_workspace_symbols, desc = 'live workspace symbols' },
              { '<leader>lsw', fzf_lua.lsp_workspace_symbols, desc = 'workspace symbols' },
            })
          end
        end
        vim.iter(fzf_mappings):each(function(m) table.insert(keys, m) end)
      end

      return keys
    end,
    config = function()
      local lsp_kind = require('lspkind')
      local fzf = require('fzf-lua')
      local show_preview = ar.config.picker.win.show_preview

      fzf.setup({
        prompt = prompt,
        fzf_colors = true,
        fzf_opts = {
          ['--info'] = 'default', -- hidden OR inline:⏐
          ['--reverse'] = false,
          ['--scrollbar'] = '▓',
          ['--no-scrollbar'] = true,
          ['--ellipsis'] = ui.icons.misc.ellipsis,
        },
        previewers = { builtin = { toggle_behavior = 'extend' } },
        winopts = {
          border = border_style,
          height = ar.config.picker.win.fullscreen and 100 or 0.9,
          width = ar.config.picker.win.fullscreen and 400 or 0.9,
          preview = {
            border = border_style,
            wrap = 'nowrap',
            hidden = show_preview and 'nohidden' or 'hidden',
            vertical = 'up:50%',
            horizontal = show_preview and 'right:55%' or 'right:0%',
            winopts = { number = true, relativenumber = false },
          },
        },
        keymap = {
          builtin = {
            true,
            ['<Esc>'] = 'abort',
            ['<c-/>'] = 'toggle-help',
            ['<c-e>'] = 'toggle-preview',
            ['<c-=>'] = 'toggle-fullscreen',
            ['<c-d>'] = 'preview-page-down',
            ['<c-u>'] = 'preview-page-up',
          },
          fzf = {
            ['ctrl-q'] = 'select-all+accept',
            ['ctrl-e'] = 'toggle-preview',
            ['ctrl-d'] = 'preview-page-down',
            ['ctrl-u'] = 'preview-page-up',
          },
        },
        highlights = { winopts = { title = ' Highlights ' } },
        helptags = { winopts = { title = ' 󰋖 Help ' } },
        actions = {
          files = {
            ['default'] = fzf.actions.file_edit_or_qf,
            ['ctrl-l'] = fzf.actions.arg_add,
            ['ctrl-s'] = fzf.actions.file_split,
            ['ctrl-v'] = fzf.actions.file_vsplit,
            ['ctrl-t'] = fzf.actions.file_tabedit,
            ['ctrl-q'] = fzf.actions.file_sel_to_qf,
            ['alt-q'] = fzf.actions.file_sel_to_ll,
          },
        },
        files = {
          prompt = prompt,
          fd_opts = "--color never --type f --type l --hidden --no-ignore --exclude '**/.git/**' --exclude '**/node_modules/**' --exclude '**/.next/**' --exclude '**/build/**' --exclude '**/tmp/**' --exclude '**/env/**' --exclude '**/__pycache__/**' --exclude '**/.mypy_cache/**' --exclude '**/.pytest_cache/**'",
          winopts = { title = '  Files ' },
          fzf_opts = {
            ['--tiebreak'] = 'end',
            ['--no-separator'] = false,
          },
        },
        oldfiles = dropdown({
          cwd_only = true,
          winopts = { title = ' 󰋖 Help ' },
        }),
        buffers = dropdown({
          fzf_opts = { ['--delimiter'] = ' ', ['--with-nth'] = '-1..' },
          winopts = { title = ' 󰈙 Buffers ' },
          no_action_zz = true,
        }),
        keymaps = dropdown({
          winopts = { title = '   Keymaps ', width = 0.7 },
        }),
        registers = cursor_dropdown({
          winopts = { title = '  Registers ', width = 0.6 },
        }),
        grep = {
          prompt = ' ',
          winopts = { title = ' 󰈭 Grep ' },
          -- fzf_opts = {
          --   ['--keep-right'] = '',
          -- },
          debug = false,
          rg_glob = true,
          rg_opts = '--hidden --column --line-number --no-heading'
            .. " --color=always --smart-case -g '!.git' -e",
          fzf_opts = {
            ['--no-separator'] = false,
            ['--history'] = vim.fn.stdpath('data') .. '/fzf_search_hist',
          },
        },
        lsp = {
          cwd_only = true,
          symbols = {
            symbol_style = 1,
            symbol_icons = lsp_kind.symbols,
            symbol_hl = function(s) return lsp_hls[s] end,
          },
          code_actions = {
            winopts = {
              width = 0.9,
              height = 0.8,
              winopts = { title = ' 󰌵 Code Actions ' },
            },
            previewer = 'codeaction_native',
          },
        },
        jumps = {
          winopts = {
            title = '  Jumps ',
            preview = { hidden = 'nohidden' },
          },
        },
        changes = dropdown({
          prompt = '',
          winopts = {
            title = ' ⟳ Changes ',
            preview = { hidden = 'nohidden' },
          },
        }),
        diagnostics = dropdown({
          winopts = { title = '  Diagnostics ', 'DiagnosticError' },
        }),
        git = {
          files = dropdown({
            path_shorten = false, -- this doesn't use any clever strategy unlike telescope so is somewhat useless
            cmd = 'git ls-files --others --cached --exclude-standard',
            winopts = { title = '  Git Files ' },
          }),
          branches = dropdown({
            winopts = { title = '  Branches ', height = 0.3, row = 0.4 },
          }),
          status = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = '  Git Status ' },
          },
          bcommits = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = '  Buffer Commits ' },
          },
          commits = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = ' Commits' },
          },
          icons = {
            ['M'] = { icon = codicons.git.mod, color = 'yellow' },
            ['D'] = { icon = codicons.git.remove, color = 'red' },
            ['A'] = { icon = codicons.git.staged, color = 'green' },
            ['R'] = { icon = codicons.git.rename, color = 'yellow' },
            ['C'] = { icon = codicons.git.conflict, color = 'yellow' },
            ['T'] = { icon = codicons.git.mod, color = 'magenta' },
            ['?'] = { icon = codicons.git.untracked, color = 'magenta' },
          },
        },
      })

      ar.command('SessionList', list_sessions)
    end,
  },
  {
    'ibhagwan/fzf-lua',
    optional = true,
    dependencies = {
      {
        'elanmed/fzf-lua-frecency.nvim',
        specs = {
          {
            'ibhagwan/fzf-lua',
            optional = true,
            keys = function(_, keys)
              local mappings = keys or {}

              if ar.config.picker.files == 'fzf-lua' then
                local function frecency()
                  require('fzf-lua-frecency').frecency({ cwd_only = true })
                end

                table.insert(
                  mappings,
                  { '<C-p>', frecency, desc = 'find files' }
                )
              end
              return mappings
            end,
          },
        },
      },
    },
  },
  {
    'razak17/todo-comments.nvim',
    optional = true,
    opts = function()
      if ar.config.picker.variant == 'fzf-lua' then
        local todos = require('todo-comments.fzf').todo
        local function todos_fixes()
          todos({ keywords = { 'TODO', 'FIX', 'FIXME' } })
        end
        local function config_todos()
          todos({
            keywords = { 'TODO', 'FIX', 'FIXME' },
            cwd = fn.stdpath('config'),
          })
        end

        map('n', '<leader>ft', todos, { desc = 'todos' })
        map('n', '<leader>fF', todos_fixes, { desc = 'todo/fixme' })
        map('n', '<leader>fC', config_todos, { desc = 'config todo/fixme' })
      end
    end,
  },
  {
    'piersolenski/import.nvim',
    cond = function() return ar.get_plugin_cond('import.nvim', not minimal) end,
    keys = { { '<leader>fi', '<Cmd>Import<CR>', desc = 'import' } },
    cmd = { 'Import' },
    opts = {
      picker = ar.config.picker.variant ~= 'mini.pick'
          and ar.config.picker.variant
        or 'snacks',
    },
  },
  {
    'dmtrKovalenko/fff.nvim',
    cond = function() return ar.get_plugin_cond('fff.nvim') end,
    build = 'cargo build --release',
    cmd = { 'FFFFind' },
    keys = function()
      local function fff_find() require('fff').find_files() end
      local keys = {
        { 'f/', fff_find, desc = 'Open file picker' },
      }
      if ar.config.picker.files == 'fff' then
        table.insert(keys, { '<C-p>', fff_find, desc = 'fff: find files' })
      end
      return keys
    end,
    opts = {
      prompt = '🦆 ',
      hl = { normal = 'NormalFloat' },
      layout = {
        height = ar.config.picker.win.fullscreen and 1.0 or 0.9,
        width = ar.config.picker.win.fullscreen and 1.0 or 0.9,
        prompt_position = 'top',
        preview_position = 'right', -- or 'left', 'right', 'top', 'bottom'
        preview_size = 0.5,
      },
      preview = {
        enabled = ar.config.picker.win.show_preview,
        line_numbers = true,
      },
    },
  },
}
