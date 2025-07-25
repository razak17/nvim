local enabled = ar_config.plugin.main.autocommands.enable

if not ar or ar.none or not enabled then return end

local augroup, is_available = ar.augroup, ar.is_available

local fn, api, env, cmd, opt = vim.fn, vim.api, vim.env, vim.cmd, vim.opt
local falsy = ar.falsy
local decor = ar.ui.decorations
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
    and ar_config.autosave.enable
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
  command = 'setlocal formatoptions-=cro',
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
if is_available('alpha-nvim') then
  augroup('AlphaSettings', {
    event = { 'User' },
    pattern = { 'AlphaReady' },
    command = function(args)
      -- opt.foldenable = false
      opt.colorcolumn = ''
      vim.o.laststatus = 0
      map('n', 'q', '<Cmd>q<CR>', { buffer = args.buf, nowait = true })

      api.nvim_create_autocmd('BufUnload', {
        buffer = args.buf,
        callback = function() vim.o.laststatus = 3 end,
      })
    end,
  })
end

if is_available('neo-tree.nvim') then
  augroup('NeoTreeStart', {
    event = { 'BufEnter' },
    desc = 'Open Neo-Tree on startup with directory',
    command = function(args)
      if package.loaded['neo-tree'] then
        return true
      else
        local stats = vim.uv.fs_stat(api.nvim_buf_get_name(args.buf))
        if stats and stats.type == 'directory' then
          require('lazy').load({ plugins = { 'neo-tree.nvim' } })
          pcall(
            api.nvim_exec_autocmds,
            'BufEnter',
            { group = 'NeoTree_NetrwDeferred', buffer = args.buf }
          )
          return true
        end
      end
    end,
  })
end

if is_available('mini.indentscope') then
  augroup('MiniIndentscopeDisable', {
    event = { 'FileType' },
    desc = 'Disable indentscope for certain files',
    command = function()
      -- stylua: ignore
      local ignored_filetypes = {
        'aerial', 'dashboard', 'help', 'lazy', 'leetcode.nvim', 'mason', 'neo-tree',
        'NvimTree', 'neogitstatus', 'notify', 'startify', 'toggleterm', 'Trouble',
        'fzf', 'alpha', 'starter', 'dbout', 'neo-tree-popup', 'log', 'gitcommit', 'txt', 'git',
        'flutterToolsOutline', 'undotree', 'markdown', 'norg', 'org', 'orgagenda',
      }
      local ignored_buftypes = { 'nofile', 'terminal' }
      if
        vim.tbl_contains(ignored_filetypes, vim.bo.filetype)
        or vim.tbl_contains(ignored_buftypes, vim.bo.buftype)
      then
        vim.b.miniindentscope_disable = true
      end
    end,
  })
end

augroup('CmpSourceCargo', {
  event = 'BufRead',
  pattern = 'Cargo.toml',
  command = function()
    if is_available('crates.nvim') then
      require('cmp').setup.buffer({
        sources = { { name = 'crates', priority = 3, group_index = 1 } },
      })
    end
  end,
})

if is_available('persisted.nvim') then
  augroup('PersistedEvents', {
    event = { 'User' },
    pattern = 'PersistedTelescopeLoadPre',
    command = function()
      vim.schedule(function() cmd('%bd') end)
    end,
  }, {
    event = { 'User' },
    pattern = 'PersistedSavePre',
    -- Arguments are always persisted in a session and can't be removed using 'sessionoptions'
    -- so remove them when saving a session
    command = function() cmd('%argdelete') end,
  })
end

if is_available('nvim-ghost.nvim') then
  api.nvim_create_augroup('NvimGhostUserAutocommands', { clear = false })
  api.nvim_create_autocmd('User', {
    group = 'NvimGhostUserAutocommands',
    pattern = {
      'www.reddit.com',
      'www.github.com',
      'www.protectedtext.com',
      '*github.com',
    },
    command = 'setfiletype markdown',
  })
end

if is_available('smartcolumn.nvim') then
  augroup('SmartCol', {
    event = { 'BufEnter', 'CursorMoved', 'CursorMovedI', 'WinScrolled' },
    command = function(args)
      decor.set_colorcolumn(
        args.buf,
        function(colorcolumn)
          require('smartcolumn').setup_buffer(
            args.buf,
            { colorcolumn = colorcolumn }
          )
        end
      )
    end,
  })
end

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

if is_available('nvim-lspconfig') then
  float_resize_autocmd('LspInfoResize', 'lspinfo', 'LspInfo')
end

if is_available('glow.nvim') then
  float_resize_autocmd('GlowResize', 'glowpreview', 'Glow')
end

-- auto-delete fugitive buffers
augroup('Fugitive', {
  event = 'BufReadPost',
  pattern = 'fugitive://*',
  command = 'set bufhidden=delete',
})
