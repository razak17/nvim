local enabled = ar.config.plugin.main.autocommands.enable

if not ar or ar.none or not enabled then return end

local augroup = ar.augroup

local fn, api, env, cmd, opt = vim.fn, vim.api, vim.env, vim.cmd, vim.opt
local falsy = ar.falsy
local config_path = fn.stdpath('config')

augroup('CheckOutsideTime', {
  -- automatically check for changed files outside vim
  event = {
    'WinEnter',
    'BufWinEnter',
    'BufWinLeave',
    'BufRead',
    'BufEnter',
    'FocusGained',
  },
  command = function()
    if vim.o.buftype ~= 'nofile' then cmd('checktime') end
  end,
})

--- automatically clear commandline messages after a few seconds delay
--- source: https://unix.stackexchange.com/a/613645
augroup('ClearCommandLineMessages', {
  event = { 'CursorHold' },
  command = function()
    vim.defer_fn(function()
      if fn.mode() == 'n' then cmd.echon("''") end
    end, 3000)
  end,
})

augroup('TextYankHighlight', {
  event = { 'TextYankPost' },
  command = function()
    (vim.hl or vim.highlight).on_yank({
      timeout = 200,
      visual = true,
      priority = 250, -- With priority higher than the LSP references one.
      higroup = 'IncSearch',
    })
  end,
})

local save_excluded = {
  'neo-tree',
  'neo-tree-popup',
  'lua.luapad',
  'gitcommit',
  'NeogitCommitMessage',
  'DiffviewFiles',
}
local function can_save()
  return falsy(vim.bo.buftype)
    and not falsy(vim.bo.filetype)
    and vim.bo.modifiable
    and not vim.bo.readonly
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
    and ar.config.autosave.enable
  -- and ar.kitty_scrollback.enable
end

augroup('UpdateVim', {
  event = { 'FocusLost', 'InsertLeave', 'TextChanged' },
  command = function(args)
    if not vim.bo[args.buf].modified then return end
    if can_save() then cmd('silent! wall') end
  end,
}, {
  event = { 'VimResized' },
  pattern = { '*' },
  command = 'wincmd =',
}, {
  event = { 'FileChangedShellPost' },
  desc = 'Notify when file is reloaded',
  command = function()
    local L = vim.log.levels
    vim.notify('File reloaded automatically', L.INFO, { title = 'nvim' })
  end,
})

augroup('WinBehavior', {
  event = { 'BufWinEnter' },
  command = function(args)
    if vim.wo.diff then vim.diagnostic.enable(true, { buf = args.buf }) end
  end,
}, {
  event = { 'TermOpen' },
  command = function()
    if falsy(vim.bo.filetype) or not falsy(vim.bo.buftype) == '' then
      cmd.startinsert()
    end
  end,
}, {
  event = { 'BufWinLeave' },
  command = function(args)
    if vim.wo.diff then vim.diagnostic.enable(true, { buf = args.buf }) end
  end,
})

augroup('Utilities', {
  -- Auto open grep quickfix window
  event = { 'QuickFixCmdPost' },
  pattern = { '*grep*' },
  command = 'cwindow',
}, {
  ---@source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  event = { 'BufReadCmd' },
  pattern = { 'file:///*' },
  nested = true,
  command = function(args)
    cmd.bdelete({ bang = true })
    cmd.edit(vim.uri_to_fname(args.file))
  end,
}, {
  --- disable formatting in directories in third party repositories
  event = { 'BufEnter' },
  command = function(args)
    local paths = vim.split(vim.o.runtimepath, ',')
    -- NOTE: Disable formatting for all plugins
    table.insert(paths, fn.stdpath('data') .. '/lazy')
    local match = vim.iter(paths):find(function(dir)
      local path = api.nvim_buf_get_name(args.buf)
      -- HACK: Disable for my config dir manually
      if vim.startswith(path, config_path) then return false end
      if vim.startswith(path, env.VIMRUNTIME) then return true end
      return vim.startswith(path, dir)
    end)
    vim.b[args.buf].formatting_disabled = match ~= nil
  end,
}, {
  event = { 'BufWritePost' },
  pattern = { '*' },
  nested = true,
  command = function(args)
    if vim.b[args.buf].is_large_file then return end

    if falsy(vim.bo.filetype) or fn.exists('b:ftdetect') == 1 then
      cmd([[
        unlet! b:ftdetect
        filetype detect
        call v:lua.vim.notify('Filetype set to ' . &ft, "info", {})
      ]])
    end
  end,
}, {
  event = 'FileType',
  command = function() opt.formatoptions:remove({ 'c', 'r', 'o' }) end,
}, {
  event = { 'BufHidden' },
  desc = 'Delete [No Name] buffers',
  command = function(event)
    if
      event.file == ''
      and vim.bo[event.buf].buftype == ''
      and not vim.bo[event.buf].modified
    then
      vim.schedule(function() pcall(vim.api.nvim_buf_delete, event.buf, {}) end)
    end
  end,
}, {
  -- Auto create dir when saving a file, in case some intermediate directory does not exist
  -- https://github.com/LazyVim/LazyVim/blob/83bf6360a1f28a3fc1afe31ae300247fc01c7a90/lua/lazyvim/config/autocmds.lua#L116C1-L116C90
  event = { 'BufWritePre' },
  desc = 'Create intermediate dirs',
  command = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})
--------------------------------------------------------------------------------
-- Plugin specific
--------------------------------------------------------------------------------
local function float_resize_autocmd(autocmd_name, ft, command)
  augroup(autocmd_name, {
    event = 'VimResized',
    pattern = '*',
    command = function()
      if vim.bo.ft == ft then
        api.nvim_win_close(0, true)
        cmd(command)
      end
    end,
  })
end

if ar.has('nvim-lspconfig') then
  float_resize_autocmd('LspInfoResize', 'lspinfo', 'LspInfo')
end

if ar.has('glow.nvim') then
  float_resize_autocmd('GlowResize', 'glowpreview', 'Glow')
end

-- auto-delete fugitive buffers
augroup('Fugitive', {
  event = 'BufReadPost',
  pattern = 'fugitive://*',
  command = 'set bufhidden=delete',
})
