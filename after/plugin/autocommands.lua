if not rvim or not rvim.plugins.enable then return end

local fn, api = vim.fn, vim.api

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
  'man',
  'notify',
  'NvimTree',
  'lsp-installer',
  'null-ls-info',
  'packer',
  'lspinfo',
  'neotest-summary',
  'neotest-output',
  'dap-float',
  'httpResult',
  'query',
}

local smart_close_buftypes = {} -- Don't include no file buffers rvim diff buffers are nofile

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
  command = function()
    local is_unmapped = fn.hasmapto('q', 'n') == 0

    local is_eligible = is_unmapped
      or vim.wo.previewwindow
      or vim.tbl_contains(smart_close_buftypes, vim.bo.buftype)
      or vim.tbl_contains(smart_close_filetypes, vim.bo.filetype)

    if is_eligible then map('n', 'q', smart_close, { buffer = 0, nowait = true }) end
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
    vim.api.nvim_exec(
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
--- source: http//unix.stackexchange.com/a/613645
rvim.augroup('ClearCommandMessages', {
  event = { 'CmdlineLeave', 'CmdlineChanged' },
  pattern = { ':' },
  command = function()
    vim.defer_fn(function()
      if fn.mode() == 'n' then vim.cmd.echon("''") end
    end, 10000)
  end,
})

rvim.augroup('TextYankHighlight', {
  event = { 'TextYankPost' },
  command = function() vim.highlight.on_yank({ timeout = 177, higroup = 'Search' }) end,
})

rvim.augroup('UpdateVim', {
  event = { 'FocusLost', 'InsertLeave' },
  command = 'silent! wall',
}, {
  event = { 'VimResized' },
  command = 'wincmd =', -- Make windows equal size when vim resizes
})

rvim.augroup(
  'WinBehavior',
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
      if vim.wo.diff then vim.diagnostic.disable(args.buf) end
    end,
  },
  {
    event = { 'BufWinLeave' },
    command = function(args)
      if vim.wo.diff then vim.diagnostic.enable(args.buf) end
    end,
  }
)

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

if vim.env.TMUX ~= nil then
  local tmux = require('user.tmux')
  rvim.augroup('ExternalConfig', {
    event = { 'BufEnter' },
    command = function() vim.o.titlestring = tmux.title_string() end,
  }, {
    event = { 'FocusGained', 'BufReadPost', 'BufEnter' },
    command = function() tmux.set_window_title() end,
  }, {
    event = { 'VimLeave' },
    command = function() tmux.clear_pane_title() end,
  }, {
    event = { 'VimLeavePre', 'FocusLost' },
    command = function() tmux.set_statusline(true) end,
  }, {
    event = { 'ColorScheme', 'FocusGained' },
    command = function()
      -- NOTE: there is a race condition here rvim the colors
      -- for kitty to re-use need to be set AFTER the rest of the colorscheme
      -- overrides
      vim.defer_fn(function() tmux.set_statusline() end, 1)
    end,
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
  -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  event = { 'BufReadCmd' },
  pattern = { 'file:///*' },
  nested = true,
  command = function(args)
    vim.cmd.bdelete({ bang = true })
    vim.cmd.edit(vim.uri_to_fname(args.file))
  end,
}, {
  event = { 'FileType' },
  pattern = { 'gitcommit', 'gitrebase' },
  command = 'set bufhidden=delete',
}, {
  event = { 'FileType' },
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'text' },
  command = function()
    vim.opt_local.spell = true
    vim.bo.textwidth = 100
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
    if rvim.empty(vim.bo.filetype) or fn.exists('b:ftdetect') == 1 then
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

rvim.augroup('ConcealMappings', {
  event = { 'FileType' },
  command = function()
    local function toggle_coceallevel()
      local level = api.nvim_get_option_value('conceallevel', {})
      if level > 0 then vim.o.conceallevel = 0 end
      if level == 0 then vim.o.conceallevel = 2 end
    end

    local function toggle_cocealcursor()
      local level = api.nvim_get_option_value('concealcursor', {})
      if level == 'n' then vim.o.concealcursor = '' end
      if level == '' then vim.o.concealcursor = 'n' end
    end
    map('n', '<localleader>cl', toggle_coceallevel, { desc = 'toggle conceallevel' })
    map('n', '<localleader>cc', toggle_cocealcursor, { desc = 'disable concealcursor' })
  end,
})

local conceal_html_class = function(bufnr)
  local namespace = vim.api.nvim_create_namespace('HTMLClassConceal')
  local language_tree = vim.treesitter.get_parser(bufnr, 'html')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  local query = vim.treesitter.parse_query(
    'html',
    [[
    ((attribute
        (attribute_name) @att_name (#eq? @att_name "class")
        (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")))
    ]]
  )

  for _, captures, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
    local start_row, start_col, end_row, end_col = captures[2]:range()
    vim.api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = metadata[2].conceal,
    })
  end
end

rvim.augroup('HTMLClassConceal', {
  event = { 'BufEnter', 'BufWritePost', 'TextChanged', 'InsertLeave' },
  pattern = { '*.html', '*.svelte', '*.astro' },
  command = function() conceal_html_class(vim.api.nvim_get_current_buf()) end,
})
