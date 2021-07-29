local fn = vim.fn
local api = vim.api
local fmt = string.format
local contains = vim.tbl_contains

local not_eligible = not vim.bo.modifiable
  or not vim.bo.buflisted
  or vim.bo.buftype ~= "" and vim.bo.buftype ~= "terminal" and vim.wo.previewwindow

vim.api.nvim_exec(
  [[
   augroup vimrc -- Ensure all autocommands are cleared
   autocmd!
   augroup END
  ]],
  ""
)

local smart_close_filetypes = {
  "help",
  "git-status",
  "git-log",
  "gitcommit",
  "dbui",
  "fugitive",
  "fugitiveblame",
  "LuaTree",
  "NvimTree",
  "log",
  "tsplayground",
  "qf",
  "lspinfo",
  "packer",
}

local function smart_close()
  if fn.winnr "$" ~= 1 then
    api.nvim_win_close(0, true)
  end
end

rvim.augroup("SmartClose", {
  {
    -- Auto open grep quickfix window
    events = { "QuickFixCmdPost" },
    targets = { "*grep*" },
    command = "cwindow",
  },
  {
    -- Close certain filetypes by pressing q.
    events = { "FileType" },
    targets = { "*" },
    command = function()
      local is_readonly = (vim.bo.readonly or not vim.bo.modifiable) and fn.hasmapto("q", "n") == 0

      local is_eligible = vim.bo.buftype ~= ""
        or is_readonly
        or vim.wo.previewwindow
        or contains(smart_close_filetypes, vim.bo.filetype)

      if is_eligible then
        rvim.nnoremap("q", smart_close, { buffer = 0, nowait = true })
      end
    end,
  },
  {
    -- Close quick fix window if the file containing it was closed
    events = { "BufEnter" },
    targets = { "*" },
    command = function()
      if fn.winnr "$" == 1 and vim.bo.buftype == "quickfix" then
        api.nvim_buf_delete(0, { force = true })
      end
    end,
  },
  {
    -- automatically close corresponding loclist when quitting a window
    events = { "QuitPre" },
    targets = { "*" },
    modifiers = { "nested" },
    command = function()
      if vim.bo.filetype ~= "qf" then
        vim.cmd "silent! lclose"
      end
    end,
  },
})

rvim.augroup("ExternalCommands", {
  {
    -- Open images in an image viewer (probably Preview)
    events = { "BufEnter" },
    targets = { "*.png,*.jpg,*.gif" },
    command = function()
      vim.cmd(fmt('silent! "%s | :bw"', vim.g.open_command .. " " .. fn.expand "%"))
    end,
  },
})

rvim.augroup("CheckOutsideTime", {
  {
    -- automatically check for changed files outside vim
    events = { "WinEnter", "BufWinEnter", "BufWinLeave", "BufRead", "BufEnter", "FocusGained" },
    targets = { "*" },
    command = "silent! checktime",
  },
})

rvim.augroup("TrimWhitespace", {
  {
    events = { "BufWritePre" },
    targets = { "*" },
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

-- See :h skeleton
rvim.augroup("Templates", {
  {
    events = { "BufNewFile" },
    targets = { "*.sh" },
    command = "0r" .. rvim.__templates_dir .. "/skeleton.sh",
  },
  {
    events = { "BufNewFile" },
    targets = { "*.lua" },
    command = "0r" .. rvim.__templates_dir .. "/skeleton.lua",
  },
})

--- automatically clear commandline messages after a few seconds delay
--- source: http//unix.stackexchange.com/a/613645
rvim.augroup("ClearCommandMessages", {
  {
    events = { "CmdlineLeave", "CmdlineChanged" },
    targets = { ":" },
    command = function()
      vim.defer_fn(function()
        if fn.mode() == "n" then
          vim.cmd [[echon '']]
        end
      end, 10000)
    end,
  },
})

rvim.augroup("TextYankHighlight", {
  {
    -- don't execute silently in case of errors
    events = { "TextYankPost" },
    targets = { "*" },
    command = function()
      require("vim.highlight").on_yank { timeout = 77, on_visual = false, higroup = "Visual" }
    end,
  },
})

local column_exclude = { "gitcommit" }
local column_clear = {
  "dashboard",
  "Packer",
  "qf",
  "help",
  "text",
  "Trouble",
  "fugitive",
  "NvimTree",
  "log",
  "fTerm",
  "TelescopePrompt",
  "lspinfo",
  "lspinfo",
  "which_key",
  "packer",
  "slide",
}

--- Set or unset the color column depending on the filetype of the buffer and its eligibility
---@param leaving boolean?
local function check_color_column(leaving)
  if contains(column_exclude, vim.bo.filetype) then
    return
  end
  local small_window = api.nvim_win_get_width(0) <= vim.bo.textwidth + 1
  local is_last_win = #api.nvim_list_wins() == 1
  if contains(column_clear, vim.bo.filetype) or not_eligible or (leaving and not is_last_win) or small_window then
    vim.wo.colorcolumn = ""
    return
  end
  if not contains(column_clear, vim.bo.filetype) and vim.wo.colorcolumn == "" then
    vim.wo.colorcolumn = "+1"
  end
end

rvim.augroup("CustomColorColumn", {
  {
    events = { "VimResized", "FocusGained", "WinEnter", "BufEnter" },
    targets = { "*" },
    command = function()
      check_color_column()
    end,
  },
  {
    events = { "FocusLost", "WinLeave" },
    targets = { "*" },
    command = function()
      check_color_column(true)
    end,
  },
})

--- Set or unset the cursor line depending on the filetype of the buffer and its eligibility
---@param leaving boolean?
local function check_cursor_line(leaving)
  if contains(column_exclude, vim.bo.filetype) then
    return
  end
  if contains(column_clear, vim.bo.filetype) or not_eligible or leaving then
    vim.wo.cursorline = false
    return
  end
  if not contains(column_clear, vim.bo.filetype) and vim.wo.cursorline == false then
    vim.wo.cursorline = true
  end
end

rvim.augroup("CustomCursorLine", {
  {
    events = { "InsertEnter" },
    targets = { "*" },
    command = "setlocal nocursorline | autocmd InsertLeave <buffer> set cursorline",
  },
  {
    events = { "VimResized", "FocusGained", "WinEnter", "BufEnter" },
    targets = { "*" },
    command = function()
      check_cursor_line()
    end,
  },
  {
    events = { "FocusLost", "WinLeave" },
    targets = { "*" },
    command = function()
      check_cursor_line(true)
    end,
  },
})

rvim.augroup("CustomFormatOptions", {
  {
    events = { "VimEnter", "BufWinEnter", "BufRead", "BufNewFile" },
    targets = { "*" },
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
  },
})

rvim.augroup("PackerSetupInit", {
  {
    events = { "BufWritePost" },
    targets = {
      rvim.__vim_path .. "/init.lua",
      rvim.__vim_path .. "/lua/core/defaults.lua",
      rvim.__modules_dir .. "/*/*.lua",
    },
    command = function()
      local files = vim.api.nvim_eval [[sort(glob(g:plugin_config_dir .. '/*/*.lua', '', v:true))]]
      for _, file in ipairs(files) do
        vim.cmd("source " .. file)
      end
      vim.cmd [[source ~/.config/rvim/lua/core/opts.lua]]
      vim.cmd [[source ~/.config/rvim/lua/core/defaults.lua]]
      local plug = require "core.plug"
      plug.ensure_plugins()
      require("lsp.utils").toggle_autoformat()
      plug.install()
      plug.magic_compile()
      plug.load_compile()
      rvim.notify("packer compiled...", { timeout = 1000 })
    end,
  },
})

rvim.augroup("UpdateVim", {
  { events = { "FocusLost" }, targets = { "*" }, command = "silent! wall" },
  -- Make windows equal size when vim resizes
  { events = { "VimResized" }, targets = { "*" }, command = "wincmd =" },
})

rvim.augroup("WinBehavior", {
  {
    events = { "Syntax" },
    targets = { "*" },
    command = [[if line('$') > 5000 | syntax sync minlines=300 | endif]],
  },
  {
    -- Force write shada on leaving nvim
    events = { "VimLeave" },
    targets = { "*" },
    command = [[if has('nvim') | wshada! | else | wviminfo! | endif]],
  },
  { events = { "FocusLost" }, targets = { "*" }, command = "silent! wall" },
  { events = { "TermOpen" }, targets = { "*:zsh" }, command = "startinsert" },
  {
    events = { "TermOpen" },
    targets = { "*" },
    command = "set laststatus=0 nocursorline nonumber norelativenumber | autocmd BufLeave <buffer> set laststatus=2",
  },
})

if vim.env.TMUX ~= nil then
  rvim.augroup("TmuxConfig", {
    {
      events = { "FocusGained", "BufReadPost", "BufReadPost", "BufReadPost", "BufEnter" },
      targets = { "*" },
      command = function()
        local session = fn.fnamemodify(vim.loop.cwd(), ":t") or "Neovim"
        local window_title = session
        window_title = fmt("%s", session)
        fn.jobstart(fmt("tmux rename-window '%s'", window_title))
      end,
    },
    {
      events = { "VimLeave" },
      targets = { "*" },
      command = function()
        fn.jobstart "tmux set-window-option automatic-rename on"
      end,
    },
  })
end

local save_excluded = { "lua.luapad" }
local function can_save()
  return rvim.empty(vim.bo.buftype)
    and not rvim.empty(vim.bo.filetype)
    and vim.bo.modifiable
    and not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

rvim.augroup("Utilities", {
  {
    -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
    events = { "BufReadCmd" },
    targets = { "file:///*" },
    command = function()
      vim.cmd(fmt("bd!|edit %s", vim.uri_from_fname "<afile>"))
    end,
  },
  {
    -- When editing a file, always jump to the last known cursor position.
    -- Don't do it for commit messages, when the position is invalid, or when
    -- inside an event handler (happens when dropping a file on gvim).
    events = { "BufReadPost" },
    targets = { "*" },
    command = function()
      local pos = fn.line "'\""
      if vim.bo.ft ~= "gitcommit" and pos > 0 and pos <= fn.line "$" then
        vim.cmd 'keepjumps normal g`"'
      end
    end,
  },
  { events = { "FileType" }, targets = { "gitcommit", "gitrebase" }, command = "set bufhidden=delete" },
  {
    events = { "BufWritePre", "FileWritePre" },
    targets = { "*" },
    command = "silent! call mkdir(expand('<afile>:p:h'), 'p')",
  },
  {
    events = { "BufLeave" },
    targets = { "*" },
    command = function()
      if can_save() then
        vim.cmd "silent! update"
      end
    end,
  },
  {
    events = { "BufWritePost" },
    targets = { "*" },
    modifiers = { "nested" },
    command = function()
      if rvim.empty(vim.bo.filetype) or fn.exists "b:ftdetect" == 1 then
        vim.cmd [[
            unlet! b:ftdetect
            filetype detect
            echom 'Filetype set to ' . &ft
          ]]
      end
    end,
  },
  {
    events = { "Syntax" },
    targets = { "*" },
    command = "if 5000 < line('$') | syntax sync minlines=200 | endif",
  },
})
