if not rvim or rvim.none then return end

local augroup, is_available, format_text =
  rvim.augroup, rvim.is_available, rvim.format_text

local fn, api, env, v, cmd, opt =
  vim.fn, vim.api, vim.env, vim.v, vim.cmd, vim.opt
local falsy = rvim.falsy
local decorations = rvim.ui.decorations

--------------------------------------------------------------------------------
-- HLSEARCH
--------------------------------------------------------------------------------
-- ref:https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/autocommands.lua

map(
  { 'n', 'v', 'o', 'i', 'c' },
  '<Plug>(StopHL)',
  'execute("nohlsearch")[-1]',
  { expr = true }
)

local function stop_hl()
  if v.hlsearch == 0 or api.nvim_get_mode().mode ~= 'n' then return end
  api.nvim_feedkeys(rvim.replace_termcodes('<Plug>(StopHL)'), 'm', false)
end

local function hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg('/'), 0)
  if not ok then return end
  local _, p_start, p_end = unpack(match)
  -- if the cursor is in a search result, leave highlighting on
  if col < p_start or col > p_end then stop_hl() end
end

augroup('VimrcIncSearchHighlight', {
  event = { 'CursorMoved' },
  command = function() hl_search() end,
}, {
  event = { 'InsertEnter' },
  command = function() stop_hl() end,
}, {
  event = { 'OptionSet' },
  pattern = { 'hlsearch' },
  command = function()
    vim.schedule(function() cmd.redrawstatus() end)
  end,
}, {
  event = 'RecordingEnter',
  command = function() vim.o.hlsearch = false end,
}, {
  event = 'RecordingLeave',
  command = function() vim.o.hlsearch = true end,
})

local smart_close_filetypes = rvim.p_table({
  ['qf'] = true,
  ['log'] = true,
  ['help'] = true,
  ['query'] = true,
  ['dap-float'] = true,
  ['dbui'] = true,
  ['lspinfo'] = true,
  ['httpResult'] = true,
  ['git.*'] = true,
  ['Neogit.*'] = true,
  ['neotest.*'] = true,
  ['fugitive.*'] = true,
  ['copilot.*'] = true,
  ['tsplayground'] = true,
  ['oil'] = true,
})

local smart_close_buftypes = rvim.p_table({
  ['nofile'] = true,
})

local function smart_close()
  if fn.winnr('$') ~= 1 then api.nvim_win_close(0, true) end
end

augroup('SmartClose', {
  -- Auto open grep quickfix window
  event = { 'QuickFixCmdPost' },
  pattern = { '*grep*' },
  command = 'cwindow',
}, {
  -- Close certain filetypes by pressing q.
  event = { 'FileType' },
  command = function(args)
    local is_unmapped = fn.hasmapto('q', 'n') == 0

    local buf = vim.bo[args.buf]
    local is_eligible = is_unmapped
      or vim.wo.previewwindow
      or smart_close_filetypes[buf.ft]
      or smart_close_buftypes[buf.bt]
    if is_eligible then
      map('n', 'q', smart_close, { buffer = args.buf, nowait = true })
    end
  end,
})

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
  command = 'silent! checktime',
})

--- automatically clear commandline messages after a few seconds delay
--- source: https://unix.stackexchange.com/a/613645
augroup('ClearCommandLineMessages', {
  event = { 'CursorHold' },
  command = function()
    vim.defer_fn(function()
      if fn.mode() == 'n' then vim.cmd.echon("''") end
    end, 3000)
  end,
})

augroup('TextYankHighlight', {
  event = { 'TextYankPost' },
  command = function()
    vim.highlight.on_yank({ timeout = 177, higroup = 'Search' })
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
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

augroup(
  'UpdateVim',
  {
    event = { 'FocusLost', 'InsertLeave', 'CursorMoved' },
    command = function(args)
      if not vim.bo[args.buf].modified or not rvim.autosave.enable then
        return
      end
      if can_save() then vim.cmd('silent! wall') end
    end,
  },
  --   {
  --   event = { 'BufLeave' },
  --   command = function()
  --     if not rvim.autosave.enable then return end
  --     if can_save() then vim.cmd('silent! write ++p') end
  --   end,
  -- },
  {
    event = { 'VimResized' },
    pattern = { '*' },
    command = 'wincmd =', -- Make windows equal size when vim resizes
  }
)

augroup('WinBehavior', {
  event = { 'BufWinEnter' },
  command = function(args)
    if vim.wo.diff then vim.diagnostic.disable(args.buf) end
  end,
}, {
  event = { 'TermOpen' },
  command = function()
    if falsy(vim.bo.filetype) or not falsy(vim.bo.buftype) == '' then
      vim.cmd.startinsert()
    end
  end,
}, {
  event = { 'BufWinLeave' },
  command = function(args)
    if vim.wo.diff then vim.diagnostic.enable(args.buf) end
  end,
})

local cursorline_exclusions =
  { 'alpha', 'TelescopePrompt', 'CommandTPrompt', 'DressingInput' }
---@param buf number
---@return boolean
local function should_show_cursorline(buf)
  return vim.bo[buf].buftype ~= 'terminal'
    and not vim.wo.previewwindow
    -- and vim.wo.winhighlight == ''
    and vim.bo[buf].filetype ~= ''
    and not vim.tbl_contains(cursorline_exclusions, vim.bo[buf].filetype)
end

augroup('Cursorline', {
  event = { 'BufEnter', 'InsertLeave' },
  command = function(args) vim.wo.cursorline = should_show_cursorline(args.buf) end,
}, {
  event = { 'BufLeave', 'InsertEnter' },
  command = function() vim.wo.cursorline = false end,
})

augroup('Utilities', {
  ---@source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  event = { 'BufReadCmd' },
  pattern = { 'file:///*' },
  nested = true,
  command = function(args)
    vim.cmd.bdelete({ bang = true })
    vim.cmd.edit(vim.uri_to_fname(args.file))
  end,
}, {
  --- disable formatting in directories in third party repositories
  event = { 'BufEnter' },
  command = function(args)
    local paths = vim.split(vim.o.runtimepath, ',')
    local match = vim.iter(paths):find(function(dir)
      local path = api.nvim_buf_get_name(args.buf)
      -- HACK: Disable for my config dir manually
      if vim.startswith(path, fn.stdpath('config')) then return false end
      if vim.startswith(path, env.VIMRUNTIME) then return true end
      return vim.startswith(path, dir)
    end)
    vim.b[args.buf].formatting_disabled = match ~= nil
  end,
}, {
  event = { 'BufWritePost' },
  pattern = { '*' },
  nested = true,
  command = function()
    if falsy(vim.bo.filetype) or fn.exists('b:ftdetect') == 1 then
      vim.cmd([[
        unlet! b:ftdetect
        filetype detect
        call v:lua.vim.notify('Filetype set to ' . &ft, "info", {})
      ]])
    end
  end,
}, {
  event = 'FileType',
  -- command = function()
  --   vim.opt_local.formatoptions:remove('c')
  --   vim.opt_local.formatoptions:remove('r')
  --   vim.opt_local.formatoptions:remove('o')
  -- end,
  command = 'setlocal formatoptions-=o',
}, {
  event = { 'BufEnter' },
  command = function(args)
    if vim.bo[args.buf].filetype == 'DiffviewFiles' then
      map(
        'n',
        'Q',
        function()
          vim.cmd(
            'lua require("neogit.integrations.diffview").diffview_mappings["close"]()'
          )
        end,
        { buffer = args.buf }
      )
    end
  end,
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
})
--------------------------------------------------------------------------------
-- Plugin specific
--------------------------------------------------------------------------------
if is_available('alpha-nvim') then
  augroup('AlphaSettings', {
    event = { 'User' },
    pattern = { 'AlphaReady' },
    command = function(args)
      opt.foldenable = false
      opt.colorcolumn = ''
      vim.o.laststatus = 0
      map('n', 'q', '<Cmd>Alpha<CR>', { buffer = args.buf, nowait = true })

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
    command = function()
      if package.loaded['neo-tree'] then
        vim.api.nvim_del_augroup_by_name('NeoTreeStart')
      else
        local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
        if stats and stats.type == 'directory' then
          vim.api.nvim_del_augroup_by_name('NeoTreeStart')
          require('neo-tree')
        end
      end
    end,
  })
end

if is_available('mini.indentscope') then
  augroup('IndentscopeDisable', {
    event = { 'FileType' },
    desc = 'Disable indentscope for certain files',
    command = function()
      -- stylua: ignore
      local ignore_filetypes = {
        'aerial', 'dashboard', 'help', 'lazy', 'leetcode.nvim', 'mason', 'neo-tree',
        'NvimTree', 'neogitstatus', 'notify', 'startify', 'toggleterm', 'Trouble',
        'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit', 'txt', 'git',
        'flutterToolsOutline', 'undotree', 'markdown', 'norg', 'org', 'orgagenda',
      }
      if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
        vim.b.miniindentscope_disable = true
      end
    end,
  })
end

-- if is_available('gitsigns.nvim') then
--   augroup('GitSignsRefreshCustom', {
--     event = { 'InsertEnter', 'CursorHold' },
--     command = function(args)
--       local decs = rvim.ui.decorations.get({
--         ft = vim.bo.ft,
--         bt = vim.bo.bt,
--         setting = 'statuscolumn',
--       })
--       if not decs or decs.ft == false or decs and decs.bt == false then
--         return
--       end
--
--       local lnum = vim.v.lnum
--       local signs = vim.api.nvim_buf_get_extmarks(
--         args.buf,
--         -1,
--         { lnum, 0 },
--         { lnum, -1 },
--         { details = true, type = 'sign' }
--       )
--       local function get_signs()
--         return vim
--           .iter(signs)
--           :map(function(item) return format_text(item[4], 'sign_text') end)
--           :fold({}, function(_, item) return item.sign_hl_group end)
--       end
--
--       local sns = get_signs()
--       if sns ~= 'GitSignsStagedAdd' then return end
--
--       vim.defer_fn(function()
--         local inner_sns = get_signs()
--         if inner_sns ~= 'GitSignsStagedAdd' then return end
--         vim.cmd('silent! lua require("gitsigns").refresh()')
--         vim.notify('gitsigns refreshed', 'info', { title = 'gitsigns' })
--       end, 500)
--     end,
--   })
-- end

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
      decorations.set_colorcolumn(
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
elseif is_available('virt-column.nvim') then
  augroup('VirtCol', {
    event = { 'VimEnter', 'BufEnter', 'WinEnter' },
    command = function(args)
      decorations.set_colorcolumn(
        args.buf,
        function(colorcolumn)
          require('virt-column').setup_buffer(
            args.buf,
            { virtcolumn = colorcolumn }
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
        vim.api.nvim_win_close(0, true)
        vim.cmd(command)
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

-- disable mini.indentscope for certain filetype|buftype
augroup('MiniIndentscopeDisable', {
  event = { 'FileType', 'BufEnter' },
  pattern = '*',
  command = "if index(['fzf', 'help'], &ft) >= 0 "
    .. "|| index(['nofile', 'terminal'], &bt) >= 0 "
    .. '| let b:miniindentscope_disable=v:true | endif',
})

-- auto-delete fugitive buffers
augroup('Fugitive', {
  event = 'BufReadPost',
  pattern = 'fugitive://*',
  command = 'set bufhidden=delete',
})
