local fn = vim.fn
local api = vim.api
local fmt = string.format

local smart_close_filetypes = {
  'help',
  'git-status',
  'git-log',
  'gitcommit',
  'dbui',
  'LuaTree',
  'log',
  'tsplayground',
  'qf',
  'NvimTree',
  'lsp-installer',
  'null-ls-info',
  'packer',
  'lspinfo',
  'neotest-summary',
}

local smart_close_buftypes = {} -- Don't include no file buffers rvim diff buffers are nofile

local function smart_close()
  if fn.winnr('$') ~= 1 then
    api.nvim_win_close(0, true)
  end
end

-- FIXME: Causing problems telescope mappings keymap
rvim.augroup('SmartClose', {
  {
    -- Auto open grep quickfix window
    event = { 'QuickFixCmdPost' },
    pattern = { '*grep*' },
    command = 'cwindow',
  },
  {
    -- Close certain filetypes by pressing q.
    event = { 'FileType' },
    pattern = { '*' },
    command = function()
      local is_unmapped = fn.hasmapto('q', 'n') == 0

      local is_eligible = is_unmapped
        or vim.wo.previewwindow
        or vim.tbl_contains(smart_close_buftypes, vim.bo.buftype)
        or vim.tbl_contains(smart_close_filetypes, vim.bo.filetype)

      if is_eligible then
        rvim.nnoremap('q', smart_close, { buffer = 0, nowait = true })
      end
    end,
  },
  {
    -- Close quick fix window if the file containing it was closed
    event = { 'BufEnter' },
    pattern = { '*' },
    nested = true,
    command = function()
      if fn.winnr('$') == 1 and vim.bo.buftype == 'quickfix' then
        api.nvim_buf_delete(0, { force = true })
      end
    end,
  },
  {
    -- automatically close corresponding loclist when quitting a window
    event = { 'QuitPre' },
    pattern = { '*' },
    nested = true,
    command = function()
      if vim.bo.filetype ~= 'qf' then
        vim.cmd('silent! lclose')
      end
    end,
  },
})

rvim.augroup('ExternalCommands', {
  {
    -- Open images in an image viewer (probably Preview)
    event = { 'BufEnter' },
    pattern = { '*.png', '*.jpg', '*.gif' },
    command = function()
      vim.cmd(fmt('silent! "%s | :bw"', rvim.open_command .. ' ' .. fn.expand('%')))
    end,
  },
})

rvim.augroup('CheckOutsideTime', {
  {
    -- automatically check for changed files outside vim
    event = { 'WinEnter', 'BufWinEnter', 'BufWinLeave', 'BufRead', 'BufEnter', 'FocusGained' },
    pattern = { '*' },
    command = 'silent! checktime',
  },
})

rvim.augroup('TrimWhitespace', {
  {
    event = { 'BufWritePre' },
    pattern = { '*' },
    command = function()
      vim.api.nvim_exec(
        [[
        let bsave = winsaveview()
        keeppatterns %s/\s\+$//e
        call winrestview(bsave)
      ]],
        false
      )
    end,
  },
})

--- automatically clear commandline messages after a few seconds delay
--- source: http//unix.stackexchange.com/a/613645
rvim.augroup('ClearCommandMessages', {
  {
    event = { 'CmdlineLeave', 'CmdlineChanged' },
    pattern = { ':' },
    command = function()
      vim.defer_fn(function()
        if fn.mode() == 'n' then
          vim.cmd([[echon '']])
        end
      end, 10000)
    end,
  },
})

rvim.augroup('TextYankHighlight', {
  {
    -- don't execute silently in case of errors
    event = { 'TextYankPost' },
    pattern = { '*' },
    command = function()
      require('vim.highlight').on_yank({ timeout = 277, on_visual = false, higroup = 'Visual' })
    end,
  },
})

local column_exclude = { 'gitcommit' }
local column_block_list = {
  'DiffViewFileHistory',
  'log',
  'norg',
  'dashboard',
  'Packer',
  'qf',
  'help',
  'text',
  'Trouble',
  'NvimTree',
  'log',
  'fTerm',
  'TelescopePrompt',
  'lspinfo',
  'lsp-installer',
  'null-ls-info',
  'lspinfo',
  'which_key',
  'packer',
  'dap-repl',
}
local function check_color_column()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buffer = vim.bo[api.nvim_win_get_buf(win)]
    local window = vim.wo[win]
    if fn.win_gettype() == '' and not vim.tbl_contains(column_exclude, buffer.filetype) then
      local too_small = api.nvim_win_get_width(win) <= buffer.textwidth + 1
      local is_excluded = vim.tbl_contains(column_block_list, buffer.filetype)
      if is_excluded or too_small then
        window.colorcolumn = ''
      elseif window.colorcolumn == '' then
        window.colorcolumn = '+1'
      end
    end
  end
end

rvim.augroup('CustomColorColumn', {
  {
    event = { 'BufEnter', 'WinNew', 'WinClosed', 'FileType', 'VimResized' },
    command = check_color_column,
  },
})

rvim.augroup('CustomFormatOptions', {
  {
    event = { 'VimEnter', 'BufWinEnter', 'BufRead', 'BufNewFile' },
    pattern = { '*' },
    command = 'setlocal formatoptions-=c formatoptions-=r formatoptions-=o',
  },
})
local config_dir = rvim.get_config_dir
local user_dir = rvim.get_user_dir
rvim.augroup('UpdateVim', {
  {
    -- TODO: not clear what effect this has in the post vimscript world
    -- it correctly sources $MYVIMRC but all the other files that it
    -- requires will need to be resourced or reloaded themselves
    event = 'BufWritePost',
    pattern = {
      config_dir() .. '/plugin/*.{lua,vim}',
      config_dir() .. '/init.{lua,vim}',
      user_dir() .. '/config/*.{lua,vim}',
      user_dir() .. '/core/*.{lua,vim}',
    },
    nested = true,
    command = function()
      -- rvim.source(config_dir() .. '/init.lua')
      rvim.invalidate(config_dir() .. '/init.lua', true)
      rvim.invalidate(config_dir() .. '/defaults.lua', true)
      -- plugins
      vim.cmd(':PlugInvalidate')
      vim.notify('Config has been reloaded', nil, { title = 'rVim' })
    end,
  },
  -- Make windows equal size when vim resizes
  { event = { 'VimResized' }, pattern = { '*' }, command = 'wincmd =' },
})

rvim.augroup('WinBehavior', {
  {
    event = { 'Syntax' },
    pattern = { '*' },
    command = [[if line('$') > 5000 | syntax sync minlines=300 | endif]],
  },
  {
    -- Force write shada on leaving nvim
    event = { 'VimLeave' },
    pattern = { '*' },
    command = [[if has('nvim') | wshada! | else | wviminfo! | endif]],
  },
  {
    event = { 'FocusLost' },
    pattern = { '*' },
    command = function()
      if rvim.util.save_on_focus_lost then
        vim.cmd('silent! wall')
      end
    end,
  },
  { event = { 'TermOpen' }, pattern = { '*:zsh' }, command = 'startinsert' },
  -- Automatically jump into the quickfix window on open
  {
    event = { 'QuickFixCmdPost' },
    pattern = { '[^l]*' },
    nested = true,
    command = 'cwindow',
  },
  {
    event = { 'QuickFixCmdPost' },
    pattern = { 'l*' },
    nested = true,
    command = 'lwindow',
  },
  {
    event = { 'BufWinEnter' },
    command = function(args)
      if vim.wo.diff then
        vim.diagnostic.disable(args.buf)
      end
    end,
  },
  {
    event = { 'BufWinLeave' },
    command = function(args)
      if vim.wo.diff then
        vim.diagnostic.enable(args.buf)
      end
    end,
  },
})

local cursorline_exclusion = { 'dashboard' }
local function should_show_cursorline()
  return vim.bo.buftype ~= 'terminal'
    and not vim.wo.previewwindow
    and vim.wo.winhighlight == ''
    and vim.bo.filetype ~= ''
    and not vim.tbl_contains(cursorline_exclusion, vim.bo.filetype)
end

rvim.augroup('Cursorline', {
  {
    event = { 'BufEnter' },
    pattern = { '*' },
    command = function()
      vim.wo.cursorline = should_show_cursorline()
    end,
  },
  {
    event = { 'BufLeave' },
    pattern = { '*' },
    command = function()
      vim.wo.cursorline = should_show_cursorline()
    end,
  },
})

if vim.env.TMUX ~= nil then
  local external = require('user.utils.external')
  rvim.augroup('ExternalConfig', {
    {
      event = { 'BufEnter' },
      pattern = { '*' },
      command = function()
        vim.o.titlestring = external.title_string()
      end,
    },
    {
      event = { 'FocusGained', 'BufReadPost', 'BufEnter' },
      pattern = { '*' },
      command = function()
        external.tmux.set_window_title()
      end,
    },
    {
      event = { 'VimLeave' },
      pattern = { '*' },
      command = function()
        external.tmux.clear_pane_title()
      end,
    },
    {
      event = { 'VimLeavePre', 'FocusLost' },
      pattern = { '*' },
      command = function()
        external.tmux.set_statusline(true)
      end,
    },
    {
      event = { 'ColorScheme', 'FocusGained' },
      pattern = { '*' },
      command = function()
        -- NOTE: there is a race condition here rvim the colors
        -- for kitty to re-use need to be set AFTER the rest of the colorscheme
        -- overrides
        vim.defer_fn(function()
          external.tmux.set_statusline()
        end, 1)
      end,
    },
  })
end

local save_excluded = {
  'neo-tree',
  'neo-tree-popup',
  'lua.luapad',
  'gitcommit',
  'NeogitCommitMessage',
}
local function can_save()
  return rvim.empty(vim.bo.buftype)
    and not rvim.empty(vim.bo.filetype)
    and vim.bo.modifiable
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

rvim.augroup('Utilities', {
  {
    -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
    event = { 'BufReadCmd' },
    pattern = { 'file:///*' },
    nested = true,
    command = function(args)
      vim.cmd(fmt('bd!|edit %s', vim.uri_to_fname(args.file)))
    end,
  },
  {
    -- When editing a file, always jump to the last known cursor position.
    -- Don't do it for commit messages, when the position is invalid.
    event = { 'BufReadPost' },
    pattern = { '*' },
    command = function()
      if vim.bo.ft ~= 'gitcommit' and vim.fn.win_gettype() ~= 'popup' then
        local last_place_mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_nr = last_place_mark[1]
        local last_line = vim.api.nvim_buf_line_count(0)

        if line_nr > 0 and line_nr <= last_line then
          vim.api.nvim_win_set_cursor(0, last_place_mark)
        end
      end
    end,
  },
  {
    event = { 'FileType' },
    pattern = { 'gitcommit', 'gitrebase' },
    command = 'set bufhidden=delete',
  },
  {
    event = { 'BufWritePre', 'FileWritePre' },
    pattern = { '*' },
    command = "silent! call mkdir(expand('<afile>:p:h'), 'p')",
  },
  {
    event = { 'BufLeave' },
    pattern = { '*' },
    command = function()
      if can_save() then
        vim.cmd('silent! update')
      end
    end,
  },
  {
    event = { 'BufWritePost' },
    pattern = { '*' },
    nested = true,
    command = function()
      -- detect filetype onsave
      if rvim.empty(vim.bo.filetype) or fn.exists('b:ftdetect') == 1 then
        vim.cmd([[
            unlet! b:ftdetect
            filetype detect
            echom 'Filetype set to ' . &ft
          ]])
      end
    end,
  },
})

-- rvim.augroup("RememberFolds", {
--   {
--     event = { "BufWinLeave" },
--     pattern = { "*" },
--     command = function()
--       if can_save() then
--         vim.cmd "mkview"
--       end
--     end,
--   },
--   {
--     event = { "BufWinEnter" },
--     pattern = { "*" },
--     command = function()
--       if can_save() then
--         vim.cmd "silent! loadview"
--       end
--     end,
--   },
-- })

rvim.augroup('TerminalAutocommands', {
  {
    event = { 'TermClose' },
    pattern = { '*' },
    command = function()
      --- automatically close a terminal if the job was successful
      if not vim.v.event.status == 0 then
        vim.cmd('bdelete! ' .. fn.expand('<abuf>'))
      end
    end,
  },
})
