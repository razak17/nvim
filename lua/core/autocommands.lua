local fn = vim.fn
local api = vim.api
local fmt = string.format
local contains = vim.tbl_contains

local column_exclude = {"gitcommit"}
local column_clear = {
  "dashboard", "Packer", "qf", "help", "text", "Trouble", "fugitive"
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

r17.augroup("VimrcIncSearchHighlight", {
  {
    -- automatically clear search highlight once leaving the commandline
    events = {"CmdlineEnter"},
    targets = {"[/\\?]"},
    command = ":set hlsearch  | redrawstatus"
  }, {
    events = {"CmdlineLeave"},
    targets = {"[/\\?]"},
    command = ":set nohlsearch | redrawstatus"
  }
})

r17.augroup("ExternalCommands", {
  {
    -- Open images in an image viewer (probably Preview)
    events = {"BufEnter"},
    targets = {"*.png,*.jpg,*.gif"},
    command = function()
      vim.cmd(fmt('silent! "%s | :bw"',
                  vim.g.open_command .. " " .. fn.expand("%")))
    end
  }
})

r17.augroup("CheckOutsideTime", {
  {
    -- automatically check for changed files outside vim
    events = {
      "WinEnter", "BufWinEnter", "BufWinLeave", "BufRead", "BufEnter",
      "FocusGained"
    },
    targets = {"*"},
    command = "silent! checktime"
  }, {events = {"BufLeave"}, targets = {"*"}, command = "silent! update"}
})

r17.augroup("TrimWhitespace", {
  {
    events = {"BufWritePre"},
    targets = {"*"},
    command = function() require("internal.utils").TrimWhitespace() end
  }
})

-- See :h skeleton
r17.augroup("Templates", {
  {
    events = {"BufNewFile"},
    targets = {"*.sh"},
    command = "0r $DOTFILES/.config/nvim/templates/skeleton.sh"
  }, {
    events = {"BufNewFile"},
    targets = {"*.lua"},
    command = "0r $DOTFILES/.config/nvim/templates/skeleton.lua"
  }
})

--- automatically clear commandline messages after a few seconds delay
--- source: http//unix.stackexchange.com/a/613645
local id
r17.augroup("ClearCommandMessages", {
  {
    events = {"CmdlineLeave", "CmdlineChanged"},
    targets = {":"},
    command = function()
      if id then fn.timer_stop(id) end
      id = fn.timer_start(2000, function()
        if fn.mode() == "n" then vim.cmd [[echon '']] end
      end)
    end
  }
})

r17.augroup("TextYankHighlight", {
  {
    -- don't execute silently in case of errors
    events = {"TextYankPost"},
    targets = {"*"},
    command = function()
      require("vim.highlight").on_yank({
        timeout = 77,
        on_visual = false,
        higroup = "Visual"
      })
    end
  }
})

r17.augroup("CustomColorColumn", {
  {
    events = {"FileType"},
    targets = column_clear,
    command = "setlocal nocursorline colorcolumn=0"
  }, {
    -- Update the cursor column to match current window size
    events = {"VimResized", "FocusGained", "WinEnter", "BufEnter"},
    targets = {"*"},
    command = function() check_color_column() end
  }, {
    events = {"FocusLost", "WinLeave"},
    targets = {"*"},
    command = function() check_color_column(true) end
  }
})

r17.augroup("WinUtils", {
  {events = {"FocusLost"}, targets = {"*"}, command = "silent! wall"}, {
    -- Equalize window dimensions when resizing vim window
    events = {"VimResized"},
    targets = {"*"},
    command = [[tabdo wincmd =]]
  }, {
    -- Force write shada on leaving nvim
    events = {"VimLeave"},
    targets = {"*"},
    command = [[if has('nvim') | wshada! | else | wviminfo! | endif]]
  }
})

r17.augroup("TerminalMode", {
  {events = {"TermOpen"}, targets = {"*:zsh"}, command = "startinsert"}, {
    events = {"TermOpen"},
    targets = {"*:zsh"},
    command = "set laststatus=0 nocursorline nonumber norelativenumber | autocmd BufLeave <buffer> set laststatus=2"
  }
})

-- Plugins
if vim.env.TMUX ~= nil then
  r17.augroup("TmuxConfig", {
    {
      events = {
        "FocusGained", "BufReadPost", "BufReadPost", "BufReadPost", "BufEnter"
      },
      targets = {"*"},
      command = function() require("internal.utils").tmux_on_enter() end
    }, {
      events = {"VimLeave"},
      targets = {"*"},
      command = function() require("internal.utils").tmux_on_leave() end
    }
  })
end

r17.augroup("PackerMagic", {
  {
    events = {"VimEnter"},
    targets = {"*"},
    command = function() require'core.plug'.magic_compile() end
  }
})
