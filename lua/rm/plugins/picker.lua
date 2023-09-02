local fn, env, ui, reqcall = vim.fn, vim.env, rvim.ui, rvim.reqcall
local codicons, lsp_hls = ui.codicons, ui.lsp.highlights
local prompt = ' ' .. codicons.misc.search_alt .. '  '

local fzf_lua = reqcall('fzf-lua') ---@module 'fzf-lua'
--------------------------------------------------------------------------------
-- FZF-LUA HELPERS
--------------------------------------------------------------------------------
local function format_title(str, icon, icon_hl)
  return {
    { ' ' },
    { (icon and icon .. ' ' or ''), icon_hl or 'DevIconDefault' },
    { str, 'Bold' },
    { ' ' },
  }
end

local file_picker = function(cwd) fzf_lua.files({ cwd = cwd }) end

local function git_files_cwd_aware(opts)
  opts = opts or {}
  local fzf = require('fzf-lua')
  -- git_root() will warn us if we're not inside a git repo
  -- so we don't have to add another warning here, if
  -- you want to avoid the error message change it to:
  -- local git_root = fzf_lua.path.git_root(opts, true)
  local git_root = fzf.path.git_root(opts)
  if not git_root then return fzf.files(opts) end
  local relative = fzf.path.relative(vim.uv.cwd(), git_root)
  opts.fzf_opts = { ['--query'] = git_root ~= relative and relative or nil }
  return fzf.git_files(opts)
end

local function dropdown(opts)
  opts = opts or { winopts = {} }
  local title = vim.tbl_get(opts, 'winopts', 'title') ---@type string?
  if title and type(title) == 'string' then
    opts.winopts.title = format_title(title)
  end
  return vim.tbl_deep_extend('force', {
    prompt = prompt,
    fzf_opts = { ['--layout'] = 'reverse' },
    winopts = {
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
    winopts = {
      row = 1,
      relative = 'cursor',
      height = 0.33,
      width = math.min(math.floor(vim.o.columns * 0.5), 100),
    },
  }, opts))
end

local function list_sessions()
  local fzf = require('fzf-lua')
  local ok, persisted = rvim.pcall(require, 'persisted')
  if not ok then return end
  local sessions = persisted.list()
  fzf.fzf_exec(
    vim.tbl_map(function(s) return s.name end, sessions),
    dropdown({
      winopts = {
        title = format_title('Sessions', '󰆔'),
        height = 0.33,
        row = 0.5,
      },
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

rvim.fzf = { dropdown = dropdown, cursor_dropdown = cursor_dropdown }
--------------------------------------------------------------------------------

return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      -- { '<c-p>', git_files_cwd_aware, desc = 'find files' },
      -- { '<leader>f?', fzf_lua.help_tags, desc = 'help' },
      -- { '<leader>fa', '<Cmd>FzfLua<CR>', desc = 'builtins' },
      -- { '<leader>fb', fzf_lua.grep_curbuf, desc = 'current buffer fuzzy find' },
      { '<leader>ff', file_picker, desc = 'find files' },
      -- { '<leader>fh', fzf_lua.oldfiles, desc = 'Most (f)recently used files' },
      -- { '<leader>fm', fzf_lua.changes, desc = 'changes' },
      -- { '<leader>fo', fzf_lua.buffers, desc = 'buffers' },
      -- { '<leader>fr', fzf_lua.resume, desc = 'resume picker' },
      { '<leader>fs', fzf_lua.live_grep, desc = 'live grep' },
      -- { '<leader>fw', fzf_lua.grep_cword, desc = 'grep cword' },
      -- { '<leader>fva', fzf_lua.autocmds, desc = 'autocommands' },
      -- { '<leader>fvh', fzf_lua.highlights, desc = 'highlights' },
      -- { '<leader>fvk', fzf_lua.keymaps, desc = 'keymaps' },
      -- { '<leader>fvr', fzf_lua.registers, desc = 'Registers' },
      -- { '<leader>fvc', fzf_lua.commands, desc = 'Commands' },
      -- { '<leader>fgb', fzf_lua.git_branches, desc = 'branches' },
      -- { '<leader>fgB', fzf_lua.git_bcommits, desc = 'buffer commits' },
      -- { '<leader>fgc', fzf_lua.git_commits, desc = 'commits' },
      -- { '<leader>ld', fzf_lua.lsp_document_symbols, desc = 'document symbols' },
      -- { '<leader>lI', fzf_lua.lsp_implementations, desc = 'search implementation' },
      -- { '<leader>lR', fzf_lua.lsp_references, desc = 'show references' },
      -- { '<leader>ls', fzf_lua.lsp_live_workspace_symbols, desc = 'workspace symbols' },
      -- { '<leader>le', fzf_lua.diagnostics_document, desc = 'document diagnostics' },
      -- { '<leader>lw', fzf_lua.diagnostics_workspace, desc = 'workspace diagnostics' },
      -- { '<leader>fc', function() file_picker(vim.fn.stdpath('config')) end, desc = 'nvim config' },
      {
        '<localleader>of',
        function() file_picker(env.HOME .. '/Sync/notes/obsidian') end,
        desc = 'obsidian: find notes',
      },
      {
        '<leader>fP',
        function() file_picker(vim.fn.stdpath('data') .. '/lazy') end,
        desc = 'plugins',
      },
    },
    config = function()
      local lsp_kind = require('lspkind')
      local fzf = require('fzf-lua')

      fzf.setup({
        fzf_opts = {
          ['--info'] = 'default', -- hidden OR inline:⏐
          ['--reverse'] = false,
          ['--scrollbar'] = '▓',
          ['--ellipsis'] = ui.icons.misc.ellipsis,
        },
        fzf_colors = {
          ['fg'] = { 'fg', 'CursorLine' },
          ['bg'] = { 'bg', 'Normal' },
          ['hl'] = { 'fg', 'Comment' },
          ['fg+'] = { 'fg', 'Normal' },
          ['bg+'] = { 'bg', 'CursorLine' },
          ['hl+'] = { 'fg', 'CursorLineNr', 'italic' },
          ['info'] = { 'fg', 'Comment', 'italic' },
          ['prompt'] = { 'fg', 'Underlined' },
          ['pointer'] = { 'fg', 'Exception' },
          ['marker'] = { 'fg', '@character' },
          ['spinner'] = { 'fg', 'DiagnosticOk' },
          ['header'] = { 'fg', 'Comment' },
          ['gutter'] = { 'bg', 'Normal' },
          ['separator'] = { 'fg', 'Comment' },
        },
        previewers = {
          builtin = { toggle_behavior = 'extend' },
        },
        winopts = {
          border = ui.border.rectangle,
          hl = { border = 'PickerBorder', preview_border = 'PickerBorder' },
        },
        keymap = {
          builtin = {
            ['<c-/>'] = 'toggle-help',
            ['<c-e>'] = 'toggle-preview',
            ['<c-=>'] = 'toggle-fullscreen',
            ['<c-f>'] = 'preview-page-down',
            ['<c-b>'] = 'preview-page-up',
          },
          fzf = {
            ['esc'] = 'abort',
            ['ctrl-q'] = 'select-all+accept',
          },
        },
        highlights = {
          prompt = prompt,
          winopts = { title = format_title('Highlights') },
        },
        helptags = {
          prompt = prompt,
          winopts = { title = format_title('Help', '󰋖') },
        },
        oldfiles = dropdown({
          cwd_only = true,
          winopts = { title = format_title('History', '') },
        }),
        files = dropdown({
          winopts = { title = format_title('Files', '') },
        }),
        buffers = dropdown({
          fzf_opts = { ['--delimiter'] = "' '", ['--with-nth'] = '-1..' },
          winopts = { title = format_title('Buffers', '󰈙') },
        }),
        keymaps = dropdown({
          winopts = { title = format_title('Keymaps', ''), width = 0.7 },
        }),
        registers = cursor_dropdown({
          winopts = { title = format_title('Registers', ''), width = 0.6 },
        }),
        grep = {
          prompt = ' ',
          winopts = { title = format_title('Grep', '󰈭') },
          fzf_opts = {
            ['--keep-right'] = '',
          },
        },
        lsp = {
          cwd_only = true,
          symbols = {
            symbol_style = 1,
            symbol_icons = lsp_kind.symbols,
            symbol_hl = function(s) return lsp_hls[s] end,
          },
          code_actions = cursor_dropdown({
            winopts = { title = format_title('Code Actions', '󰌵', '@type') },
          }),
        },
        jumps = dropdown({
          winopts = {
            title = format_title('Jumps', ''),
            preview = { hidden = 'nohidden' },
          },
        }),
        changes = dropdown({
          prompt = '',
          winopts = {
            title = format_title('Changes', '⟳'),
            preview = { hidden = 'nohidden' },
          },
        }),
        diagnostics = dropdown({
          winopts = {
            title = format_title('Diagnostics', '', 'DiagnosticError'),
          },
        }),
        git = {
          files = dropdown({
            path_shorten = false, -- this doesn't use any clever strategy unlike telescope so is somewhat useless
            cmd = 'git ls-files --others --cached --exclude-standard',
            winopts = { title = format_title('Git Files', '') },
          }),
          branches = dropdown({
            winopts = {
              title = format_title('Branches', ''),
              height = 0.3,
              row = 0.4,
            },
          }),
          status = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = format_title('Git Status', '') },
          },
          bcommits = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = format_title('', 'Buffer Commits') },
          },
          commits = {
            prompt = '',
            preview_pager = 'delta --width=$FZF_PREVIEW_COLUMNS',
            winopts = { title = format_title('', 'Commits') },
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

      rvim.command('SessionList', list_sessions)
    end,
  },
}
