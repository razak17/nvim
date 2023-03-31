if not rvim or not rvim.plugins.enable then return end

local fn, api = vim.fn, vim.api

local smart_close_filetypes = rvim.p_table({
  ['qf'] = true,
  ['log'] = true,
  ['help'] = true,
  ['query'] = true,
  ['dbui'] = true,
  ['lspinfo'] = true,
  ['httpResult'] = true,
  ['git.*'] = true,
  ['Neogit.*'] = true,
  ['neotest.*'] = true,
  ['fugitive.*'] = true,
  ['tsplayground'] = true,
})

local function smart_close()
  if fn.winnr('$') ~= 1 then api.nvim_win_close(0, true) end
end

rvim.augroup('SmartClose', {
  -- Auto open grep quickfix window
  event = { 'QuickFixCmdPost' },
  pattern = { '*grep*' },
  command = 'cwindow',
}, {
  -- Close certain filetypes by pressing q.
  event = { 'FileType' },
  command = function(args)
    local is_unmapped = fn.hasmapto('q', 'n') == 0

    local is_eligible = is_unmapped or vim.wo.previewwindow or smart_close_filetypes[vim.bo[args.buf].ft]
    if is_eligible then map('n', 'q', smart_close, { buffer = args.buf, nowait = true }) end
  end,
})

rvim.augroup('CheckOutsideTime', {
  -- automatically check for changed files outside vim
  event = { 'WinEnter', 'BufWinEnter', 'BufWinLeave', 'BufRead', 'BufEnter', 'FocusGained' },
  command = 'silent! checktime',
})

rvim.augroup('TrimWhitespace', {
  event = { 'BufWritePre' },
  command = function()
    api.nvim_exec(
      [[
        let bsave = winsaveview()
        keeppatterns %s/\s\+$//e
        call winrestview(bsave)
      ]],
      false
    )
  end,
})

--- automatically clear commandline messages after a few seconds delay
--- source: https://unix.stackexchange.com/a/613645
rvim.augroup('ClearCommandLineMessages', {
  event = { 'CursorHold' },
  command = function()
    vim.defer_fn(function()
      if fn.mode() == 'n' then vim.cmd.echon("''") end
    end, 1000)
  end,
})

rvim.augroup('TextYankHighlight', {
  event = { 'TextYankPost' },
  command = function() vim.highlight.on_yank({ timeout = 177, higroup = 'Search' }) end,
})

rvim.augroup('UpdateVim', {
  event = { 'FocusLost', 'InsertLeave' },
  command = 'silent! wall',
})

rvim.augroup('WinBehavior', {
  event = { 'BufWinEnter' },
  command = function(args)
    if vim.wo.diff then vim.diagnostic.disable(args.buf) end
  end,
}, {
  event = { 'BufWinLeave' },
  command = function(args)
    if vim.wo.diff then vim.diagnostic.enable(args.buf) end
  end,
})

local cursorline_exclusions = { 'alpha', 'TelescopePrompt', 'CommandTPrompt', 'DressingInput' }
---@param buf number
---@return boolean
local function should_show_cursorline(buf)
  return vim.bo[buf].buftype ~= 'terminal'
    and not vim.wo.previewwindow
    -- and vim.wo.winhighlight == ''
    and vim.bo[buf].filetype ~= ''
    and not vim.tbl_contains(cursorline_exclusions, vim.bo[buf].filetype)
end

rvim.augroup('Cursorline', {
  event = { 'BufEnter', 'InsertLeave' },
  command = function(args) vim.wo.cursorline = should_show_cursorline(args.buf) end,
}, {
  event = { 'BufLeave', 'InsertEnter' },
  command = function() vim.wo.cursorline = false end,
})

local save_excluded = {
  'neo-tree',
  'neo-tree-popup',
  'lua.luapad',
  'gitcommit',
  'NeogitCommitMessage',
}
local function can_save()
  return rvim.falsy(vim.bo.buftype)
    and not rvim.falsy(vim.bo.filetype)
    and vim.bo.modifiable
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

rvim.augroup('Utilities', {
  -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  event = { 'BufReadCmd' },
  pattern = { 'file:///*' },
  nested = true,
  command = function(args)
    vim.cmd.bdelete({ bang = true })
    vim.cmd.edit(vim.uri_to_fname(args.file))
  end,
}, {
  event = { 'BufWritePre', 'FileWritePre' },
  command = "silent! call mkdir(expand('<afile>:p:h'), 'p')",
}, {
  event = { 'BufLeave' },
  command = function()
    if can_save() then vim.cmd.update({ mods = { silent = true } }) end
  end,
}, {
  event = { 'BufWritePost' },
  pattern = { '*' },
  nested = true,
  command = function()
    if rvim.falsy(vim.bo.filetype) or fn.exists('b:ftdetect') == 1 then
      vim.cmd([[
        unlet! b:ftdetect
        filetype detect
        echom 'Filetype set to ' . &ft
      ]])
    end
  end,
}, {
  event = 'FileType',
  command = function()
    vim.opt_local.formatoptions:remove('c')
    vim.opt_local.formatoptions:remove('r')
    vim.opt_local.formatoptions:remove('o')
  end,
})
