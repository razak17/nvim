local fn = vim.fn
local api = vim.api
local fmt = string.format
local contains = vim.tbl_contains

local column_exclude = {"gitcommit"}
local column_clear = {
  "dashboard",
  "Packer",
  "qf",
  "help",
  "text",
  "Trouble",
  "fugitive",
  "log",
}

--- Set or unset the color column depending on the filetype of the buffer and its eligibility
---@param leaving boolean?
local function check_color_column(leaving)
  if contains(column_exclude, vim.bo.filetype) then return end

  local not_eligible = not vim.bo.modifiable or not vim.bo.buflisted or
                         vim.bo.buftype ~= ""
  if contains(column_clear, vim.bo.filetype) or not_eligible then
    vim.cmd("setlocal colorcolumn=0")
    return
  end
  if api.nvim_win_get_width(0) <= 85 and leaving then
    -- only reset this value when it doesn't already exist
    vim.cmd("setlocal nocursorline colorcolumn=0")
  elseif leaving then
    vim.cmd("setlocal nocursorline")
  else
    vim.cmd("setlocal cursorline")
  end
end

core.augroup("CheckOutsideTime", {
  {
    -- automatically check for changed files outside vim
    events = {
      "WinEnter",
      "BufWinEnter",
      "BufWinLeave",
      "BufRead",
      "BufEnter",
      "FocusGained",
    },
    targets = {"*"},
    command = "silent! checktime",
  },
  {events = {"BufLeave"}, targets = {"*"}, command = "silent! update"},
})

core.augroup("TrimWhitespace", {
  {
    events = {"BufWritePre"},
    targets = {"*"},
    command = function()
      vim.api.nvim_exec([[
        let bsave = winsaveview()
        keeppatterns %s/\s\+$//e
        call winrestview(bsave)
      ]], false)
    end,
  },
})

-- See :h skeleton
core.augroup("Templates", {
  {
    events = {"BufNewFile"},
    targets = {"*.sh"},
    command = "0r $HOME/.config/nvim/templates/skeleton.sh",
  },
  {
    events = {"BufNewFile"},
    targets = {"*.lua"},
    command = "0r $HOME/.config/nvim/templates/skeleton.lua",
  },
})

--- automatically clear commandline messages after a few seconds delay
--- source: http//unix.stackexchange.com/a/613645
local id
core.augroup("ClearCommandMessages", {
  {
    events = {"CmdlineLeave", "CmdlineChanged"},
    targets = {":"},
    command = function()
      if id then fn.timer_stop(id) end
      id = fn.timer_start(2000, function()
        if fn.mode() == "n" then vim.cmd [[echon '']] end
      end)
    end,
  },
})

core.augroup("TextYankHighlight", {
  {
    -- don't execute silently in case of errors
    events = {"TextYankPost"},
    targets = {"*"},
    command = function()
      require("vim.highlight").on_yank({
        timeout = 77,
        on_visual = false,
        higroup = "Visual",
      })
    end,
  },
})

core.augroup("FormatOptions", {
  {events = {"BufWinEnter"}, targets = {"*"}, command = "set formatoptions-=cro"},
})

core.augroup("CustomColorColumn", {
  {
    events = {"FileType"},
    targets = column_clear,
    command = "setlocal nocursorline colorcolumn=0",
  },
  {
    -- Update the cursor column to match current window size
    events = {"VimResized", "FocusGained", "WinEnter", "BufEnter"},
    targets = {"*"},
    command = function() check_color_column() end,
  },
  {
    events = {"FocusLost", "WinLeave"},
    targets = {"*"},
    command = function() check_color_column(true) end,
  },
})

core.augroup("WinUtils", {
  {
    events = {"Syntax"},
    targets = {"*"},
    command = [[if line('$') > 5000 | syntax sync minlines=300 | endif]],
  },
  {
    -- Equalize window dimensions when resizing vim window
    events = {"VimResized"},
    targets = {"*"},
    command = [[tabdo wincmd =]],
  },
  {
    -- Force write shada on leaving nvim
    events = {"VimLeave"},
    targets = {"*"},
    command = [[if has('nvim') | wshada! | else | wviminfo! | endif]],
  },
})

core.augroup("AutoSaveOnFocusLost", {
  {events = {"FocusLost"}, targets = {"*"}, command = "silent! wall"},
})

core.augroup("TerminalMode", {
  {events = {"TermOpen"}, targets = {"*:zsh"}, command = "startinsert"},
  {
    events = {"TermOpen"},
    targets = {"*:zsh"},
    command = "set laststatus=0 nocursorline nonumber norelativenumber | autocmd BufLeave <buffer> set laststatus=2",
  },
})

-- Plugins
if vim.env.TMUX ~= nil then
  core.augroup("TmuxConfig", {
    {
      events = {
        "FocusGained",
        "BufReadPost",
        "BufReadPost",
        "BufReadPost",
        "BufEnter",
      },
      targets = {"*"},
      command = function()
        local session = fn.fnamemodify(vim.loop.cwd(), ":t") or "Neovim"
        local window_title = session
        window_title = fmt("%s", session)
        fn.jobstart(fmt("tmux rename-window '%s'", window_title))
      end,
    },
    {
      events = {"VimLeave"},
      targets = {"*"},
      command = function()
        fn.jobstart("tmux set-window-option automatic-rename on")
      end,
    },
  })
end

core.augroup("PackerMagic", {
  {
    events = {"VimEnter"},
    targets = {"*"},
    command = function() require'core.plug'.magic_compile() end,
  },
})
