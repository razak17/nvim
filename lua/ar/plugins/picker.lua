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
if ar_config.picker.variant == 'fzf-lua' then
  ar.pick.register(picker_config)
end

local fn, ui, reqcall = vim.fn, ar.ui, ar.reqcall
local codicons, lsp_hls = ui.codicons, ui.lsp.highlights
local prompt = ' ' .. codicons.misc.search_alt .. '  '
local minimal = ar.plugins.minimal

local fzf_lua = reqcall('fzf-lua') ---@module 'fzf-lua'
--------------------------------------------------------------------------------
-- FZF-LUA HELPERS
--------------------------------------------------------------------------------
local file_picker = function(cwd) fzf_lua.files({ cwd = cwd }) end

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

local function obsidian_open() file_picker(ar.sync_dir('obsidian')) end

ar.command('ObsidianFind', obsidian_open)

ar.fzf = { dropdown = dropdown, cursor_dropdown = cursor_dropdown }

return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    cond = not minimal,
    init = function()
      vim.g.whichkey_add_spec({
        { '<localleader>f', group = 'Picker' },
        { '<localleader>fg', group = 'Git' },
        { '<localleader>fv', group = 'Vim' },
      })
    end,
    -- stylua: ignore
    keys = function()
      local mappings = {}

      if ar_config.picker.files == 'fzf-lua' then
        table.insert(mappings, { '<C-p>', fzf_lua.git_files, desc = 'find files' })
      end
      if ar_config.picker.variant == 'fzf-lua' then
        local fzf_mappings = {
          { '<leader>f?', fzf_lua.help_tags, desc = 'help' },
          { '<leader>fa', '<Cmd>FzfLua<CR>', desc = 'builtins' },
          { '<leader>fb', fzf_lua.grep_curbuf, desc = 'current buffer fuzzy find' },
          { '<leader>ff', file_picker, desc = 'find files' },
          { '<leader>fh', fzf_lua.oldfiles, desc = 'Most (f)recently used files' },
          { '<leader>fm', fzf_lua.changes, desc = 'changes' },
          { '<leader>fo', fzf_lua.buffers, desc = 'buffers' },
          { '<leader>fr', fzf_lua.resume, desc = 'resume picker' },
          { '<leader>fs', fzf_lua.live_grep, desc = 'live grep' },
          { '<leader>fw', fzf_lua.grep_cword, desc = 'grep cword' },
          { '<leader>fva', fzf_lua.autocmds, desc = 'autocommands' },
          { '<leader>fvh', fzf_lua.highlights, desc = 'highlights' },
          { '<leader>fvk', fzf_lua.keymaps, desc = 'keymaps' },
          { '<leader>fvr', fzf_lua.registers, desc = 'Registers' },
          { '<leader>fvc', fzf_lua.commands, desc = 'Commands' },
          { '<leader>fgb', fzf_lua.git_branches, desc = 'branches' },
          { '<leader>fgB', fzf_lua.git_bcommits, desc = 'buffer commits' },
          { '<leader>fgc', fzf_lua.git_commits, desc = 'commits' },
          { '<leader>ld', fzf_lua.lsp_document_symbols, desc = 'document symbols' },
          { '<leader>lI', fzf_lua.lsp_implementations, desc = 'search implementation' },
          { '<leader>lR', fzf_lua.lsp_references, desc = 'show references' },
          { '<leader>ls', fzf_lua.lsp_live_workspace_symbols, desc = 'workspace symbols' },
          { '<leader>le', fzf_lua.diagnostics_document, desc = 'document diagnostics' },
          { '<leader>lw', fzf_lua.diagnostics_workspace, desc = 'workspace diagnostics' },
          { '<leader>fc', function() file_picker(fn.stdpath('config')) end, desc = 'nvim config' },
          { '<leader>fO', obsidian_open, desc = 'find notes' },
          { '<leader>fP', function() file_picker(fn.stdpath('data') .. '/lazy') end, desc = 'plugins' },
        }

        vim
          .iter(fzf_mappings)
          :each(function(m) table.insert(mappings, m) end)
      end

      return mappings
    end,
    config = function()
      local lsp_kind = require('lspkind')
      local fzf = require('fzf-lua')

      fzf.setup({
        prompt = prompt,
        fzf_opts = {
          ['--info'] = 'default', -- hidden OR inline:⏐
          ['--reverse'] = false,
          ['--scrollbar'] = '▓',
          ['--no-scrollbar'] = true,
          ['--ellipsis'] = ui.icons.misc.ellipsis,
        },
        fzf_colors = {
          ['fg'] = { 'fg', 'FzfLuaCursorLine' },
          ['bg'] = { 'bg', 'FzfLuaNormal' },
          ['hl'] = { 'fg', 'CursorLineNr' },
          ['fg+'] = { 'fg', 'FzfLuaNormal' },
          ['bg+'] = { 'bg', 'FzfLuaCursorLine' },
          ['hl+'] = { 'fg', 'FzfLuaCursorLineNr', 'italic' },
          ['info'] = { 'fg', 'CursorLineNr', 'italic' },
          ['prompt'] = { 'fg', 'Underlined' },
          ['pointer'] = { 'fg', 'Exception' },
          ['marker'] = { 'fg', '@character' },
          ['spinner'] = { 'fg', 'DiagnosticOk' },
          ['header'] = { 'fg', 'Comment' },
          ['gutter'] = { 'bg', 'FzfLuaNormal' },
          ['separator'] = { 'fg', 'Comment' },
        },
        previewers = { builtin = { toggle_behavior = 'extend' } },
        hls = {
          title = 'FloatTitle',
          border = 'FloatBorder',
          preview_border = 'FzfLuaPreviewBorder',
        },
        winopts = { border = ui.current.border },
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
          -- find_opts = [[-type f -not -path '*/\.git/*' '*/\node_modules/*' -printf '%P\n']],
          -- rg_opts = "--color=never --files --hidden --follow -g '!.git' -g '!node_modules'",
          rg_opts = '--column --hidden --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
          -- fd_opts = "--color=never --type f --hidden --follow --exclude '.git' --exclude 'node_modules' --exclude '.obsidian'",
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
          fzf_opts = { ['--delimiter'] = "' '", ['--with-nth'] = '-1..' },
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
              width = 0.7,
              height = 0.8,
              preview = {
                layout = 'vertical',
                height = 0.5,
                vertical = 'up:65%',
              },
              winopts = { title = ' 󰌵 Code Actions ', '@type' },
            },
            previewer = 'codeaction_native',
            preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS --hunk-header-style='omit' --file-style='omit'",
          },
        },
        jumps = dropdown({
          winopts = { title = '  Jumps ', preview = { hidden = 'nohidden' } },
        }),
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
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'camspiers/snap',
    cond = not minimal and false,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>f', group = 'Snap' })
    end,
    config = function()
      ar.highlight.plugin('snap', {
        theme = {
          ['onedark'] = {
            { SnapNormal = { link = 'NormalFloat' } },
            { SnapBorder = { link = 'FloatBorder' } },
          },
        },
      })
    end,
    keys = {
      {
        '<leader><leader>ff',
        function()
          local snap = require('snap')
          snap.config.file({ producer = 'ripgrep.file' })()
        end,
        desc = 'snap: find files',
      },
      {
        '<leader><leader>fg',
        function()
          local snap = require('snap')
          snap.config.vimgrep({})()
        end,
        desc = 'snap: grep string',
      },
    },
  },
}
