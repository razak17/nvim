local fn = vim.fn

local use_fd = true

---@type ArPick
local picker_config = {
  name = 'snacks',
  commands = {
    files = 'files',
    live_grep = 'grep_live',
    oldfiles = 'oldfiles',
    lsp_references = 'references',
  },

  ---@param source string
  ---@param opts? ArPickOpts
  open = function(source, opts)
    opts = opts or {}
    if opts.cwd then
      opts.source = { cwd = opts.cwd }
      opts.cwd = nil
    end
    local builtin = require('mini.pick').builtin[source]
    if builtin then return builtin({}, opts) end
    -- stylua: ignore
    local lsp_scopes = {
      'declaration', 'definition', 'document_symbol', 'implementation', 'references',
      'type_definition', 'workspace_symbol',
    }
    local scope = source
    if vim.tbl_contains(lsp_scopes, source) then source = 'lsp' end
    local extra = require('mini.extra').pickers[source]
    if not extra then return end
    return extra({ scope = scope }, {})
  end,
}
if ar_config.picker.variant == 'mini.pick' then
  ar.pick.register(picker_config)
end

---@param source string
---@param opts? table
---@param local_opts? table
---@return function
local function b(source, opts, local_opts)
  opts = opts or {}
  local_opts = local_opts or {}
  return function() MiniPick.builtin[source](local_opts, opts) end
end

---@param source string
---@param opts? table
---@param local_opts? table
---@return function
local function extra(source, opts, local_opts)
  opts = opts or {}
  local_opts = local_opts or {}
  return function() MiniExtra.pickers[source](local_opts, opts) end
end

---@param local_opts table
---@param opts? table
local function cli(local_opts, opts)
  local_opts = local_opts or {}
  opts = opts or {}
  return b('cli', opts, local_opts)
end

---@param scope string
---@param opts? table
local function list(scope, opts)
  opts = opts or {}
  return extra('list', opts, { scope = scope })
end

---@param scope string
---@param opts? table
local function lsp(scope, opts)
  opts = opts or {}
  return extra('lsp', opts, { scope = scope })
end

local function config()
  b('files', { source = { cwd = fn.stdpath('config') } })()
end

local function find_files()
  -- stylua: ignore start
  local cmd = use_fd and {
    'fd',
    '--type', 'f',
    '--type', 'l',
    '--color', 'never',
    '--hidden', '--no-ignore',
    '--exclude', '**/.git/**',
    '--exclude', '**/.next/**',
    '--exclude', '**/node_modules/**',
    '--exclude', '**/build/**',
    '--exclude', '**/tmp/**',
    '--exclude', '**/env/**',
    '--exclude', '**/__pycache__/**',
    '--exclude', '**/.mypy_cache/**',
    '--exclude', '**/.pytest_cache/**',
  } or {
    'rg',
    '--files',
    '--hidden', '--no-ignore',
    '--glob', '!**/.git/**',
    '--glob', '!**/node_modules/**',
    '--glob', '!**/build/**',
    '--glob', '!**/tmp/**',
    '--glob', '!**/.mypy_cache/**',
  }
  -- stylua: ignore end
  cli({ command = cmd }, { source = { name = 'All Files' } })()
end

local function lazy()
  local cmd = { 'fd', '--exact-depth', '2', '--ignore-case', 'readme.md' }
  cli({ command = cmd }, { source = { cwd = fn.stdpath('data') .. '/lazy' } })()
end

local function notes()
  -- stylua: ignore
  local cmd = {
    'fd',
    '--type', 'f',
    '--type', 'l',
    '--color', 'never',
    '--hidden', '--no-ignore',
    '--glob', '*.md',
    '--exclude', '**/.git/**',
    '--exclude', '**/node_modules/**',
  }
  cli({ command = cmd }, { source = { cwd = ar.sync_dir('obsidian') } })()
end

return {
  'echasnovski/mini.pick',
  cond = function()
    local condition = ar_config.picker.files == 'mini.pick'
      or ar_config.picker.variant == 'mini.pick'
    return ar.get_plugin_cond('mini.pick', condition)
  end,
  keys = function()
    local mappings = {}
    if ar_config.picker.files == 'mini.pick' then
      table.insert(mappings, { '<C-p>', find_files, desc = 'open' })
    end
    if ar_config.picker.variant == 'mini.pick' then
      local picker_mappings = {
        -- stylua: ignore start
        { '<M-space>', b('buffers'), desc = 'buffers' },
        { '<leader>fc', config, desc = 'config' },
        { '<leader>ff', find_files, desc = 'files' },
        { '<leader>fgb', extra('git_branches'), desc = 'git branches' },
        { '<leader>fgc', extra('git_commits'), desc = 'git commits' },
        { '<leader>fgd', extra('git_hunks'), desc = 'git diff' },
        { '<leader>fgg', extra('git_files'), desc = 'git files' },
        { '<leader>fh', extra('help'), desc = 'help' },
        { '<leader>fk', extra('keymaps'), desc = 'keymaps' },
        { '<leader>fo', extra('oldfiles'), desc = 'oldfiles' },
        { '<leader>fO', notes, desc = 'notes' },
        { '<leader>fql', list('location'), desc = 'loclist' },
        { '<leader>fqq', list('quickfix'), desc = 'qflist' },
        { '<leader>fr', extra('resume'), desc = 'resume' },
        { '<leader>fvc', extra('commands'), desc = 'commands' },
        { '<leader>fvC', extra('history'), desc = 'command history' },
        { '<leader>fvh', extra('hl_groups'), desc = 'highlights' },
        { '<leader>fvj', list('jump'), desc = 'jumplist' },
        { '<leader>fvm', extra('marks'), desc = 'marks' },
        { '<leader>fvo', extra('options'), desc = 'options' },
        { '<leader>fvr', extra('registers'), desc = 'registers' },
        { '<leader>fvs', extra('spellsuggest'), desc = 'spell' },
        { '<leader>fvt', extra('treesitter'), desc = 'treesitter' },
        { '<leader>fw', b('grep'), desc = 'grep' },
        { '<leader>fs', b('grep_live'), desc = 'live grep' },
        { '<leader>fla', lazy, desc = 'plugins' },
        -- lsp
        { '<leader>le', extra('diagnostic'), desc = 'mini.pick: diagnostics' },
        { '<leader>lR', lsp('references'), desc = 'mini.pick: references' },
        { '<leader>lI', lsp('implementation'), desc = 'mini.pick: implementation' },
        { '<leader>ly', lsp('type_definition'), desc = 'mini.pick: type definition' },
        -- explorer
        { '<leader>fe', extra('explorer'), desc = 'explorer' },
        -- stylua: ignore end
      }
      if
        ar_config.lsp.symbols.enable
        and ar_config.lsp.symbols.variant == 'picker'
      then
        -- stylua: ignore
        table.insert(picker_mappings, {
          '<leader>lsd', lsp('document_symbol'), desc = 'mini.pick: document symbols'
        })
        -- stylua: ignore
        table.insert(picker_mappings, {
          '<leader>lsw', lsp('workspace_symbol'), desc = 'mini.pick: workspace symbols'
        })
      end
      vim.iter(picker_mappings):each(function(m) table.insert(mappings, m) end)
    end
    return mappings
  end,
  event = 'VeryLazy',
  cmd = { 'Pick' },
  opts = { delay = { async = 10, busy = 30 } },
  config = function(_, opts)
    local picker = require('mini.pick')

    if ar_config.picker.variant == 'mini.pick' then
      vim.ui.select = picker.ui_select
    end

    local parsed_matches = function()
      local qflist = {}
      local matches = picker.get_picker_matches().all

      for _, match in ipairs(matches) do
        if type(match) == 'table' then
          table.insert(qflist, match)
        else
          local path, lnum, col, search =
            string.match(match, '(.-)%z(%d+)%z(%d+)%z%s*(.+)')
          local text = path
            and string.format('%s [%s:%s]  %s', path, lnum, col, search)
          local filename = path or vim.trim(match):match('%s+(.+)')

          table.insert(qflist, {
            filename = filename or match,
            lnum = lnum or 1,
            col = col or 1,
            text = text or match,
          })
        end
      end

      return qflist
    end

    opts.mappings = opts.mappings or {}
    opts.mappings.send_to_qflist = {
      char = '<C-q>',
      func = function()
        vim.fn.setqflist(parsed_matches(), 'r')
        if picker.is_picker_active() then picker.stop() end
        vim.cmd('copen')
      end,
    }
    picker.setup(opts)
  end,
  dependencies = { 'echasnovski/mini.extra' },
}
