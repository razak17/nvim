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
core.augroup("ClearCommandMessages", {
  {
    events = {"CmdlineLeave", "CmdlineChanged"},
    targets = {":"},
    command = function()
      vim.defer_fn(function()
        if fn.mode() == "n" then vim.cmd [[echon '']] end
      end, 10000)
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
  {
    events = {"BufWinEnter"},
    targets = {"*"},
    command = "set formatoptions-=cro",
  },
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

core.augroup("UpdateVim", {
  {
    events = {"BufWritePost"},
    targets = {
      "$MYVIMRC",
      core.__modules_dir .. "/**/*.lua",
      core.__vim_path .. '/lua/core/*.lua',
    },
    command = function()
      vim.cmd "source ~/.config/nvim/lua/core/defaults.lua"
      -- vim.cmd "source ~/.config/nvim/lua/modules/completion/telescope.lua"
      vim.cmd "source ~/.config/nvim/lua/modules/lang/lsp/lspconfig/init.lua"
      vim.cmd [[source $MYVIMRC]]
      require'core.plug'.ensure_plugins()
      vim.cmd ":PlugCompile"
      vim.cmd ":PlugInstall"
    end,
  },
  {events = {"FocusLost"}, targets = {"*"}, command = "silent! wall"},
  -- Make windows equal size when vim resizes
  {events = {"VimResized"}, targets = {"*"}, command = "wincmd ="},
})

core.augroup("WinBehavior", {
  {
    events = {"Syntax"},
    targets = {"*"},
    command = [[if line('$') > 5000 | syntax sync minlines=300 | endif]],
  },
  {
    -- Force write shada on leaving nvim
    events = {"VimLeave"},
    targets = {"*"},
    command = [[if has('nvim') | wshada! | else | wviminfo! | endif]],
  },
  {events = {"FocusLost"}, targets = {"*"}, command = "silent! wall"},
  {events = {"TermOpen"}, targets = {"*:zsh"}, command = "startinsert"},
  {
    events = {"TermOpen"},
    targets = {"*"},
    command = "set laststatus=0 nocursorline nonumber norelativenumber | autocmd BufLeave <buffer> set laststatus=2",
  },
  {events = {"InsertEnter"}, targets = {"*"}, command = "setlocal nocursorline"},
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

core.augroup("DapBehavior", {
  {
    events = {"FileType"},
    targets = {
      "dapui_scopes",
      "dapui_breakpoints",
      "dapui_stacks",
      "dapui_watches",
    },
    command = "set laststatus=0",
  },
})

local save_excluded = {"lua.luapad"}
local function can_save()
  return core.empty(vim.bo.buftype) and not core.empty(vim.bo.filetype) and
           vim.bo.modifiable and
           not vim.tbl_contains(save_excluded, vim.bo.filetype)
end

core.augroup("Utilities", {
  {
    -- @source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
    events = {"BufReadCmd"},
    targets = {"file:///*"},
    command = function()
      vim.cmd(fmt("bd!|edit %s", vim.uri_from_fname "<afile>"))
    end,
  },
  {
    -- When editing a file, always jump to the last known cursor position.
    -- Don't do it for commit messages, when the position is invalid, or when
    -- inside an event handler (happens when dropping a file on gvim).
    events = {"BufReadPost"},
    targets = {"*"},
    command = function()
      local pos = fn.line "'\""
      if vim.bo.ft ~= "gitcommit" and pos > 0 and pos <= fn.line "$" then
        vim.cmd 'keepjumps normal g`"'
      end
    end,
  },
  {
    events = {"FileType"},
    targets = {"gitcommit", "gitrebase"},
    command = "set bufhidden=delete",
  },
  {
    events = {"BufWritePre", "FileWritePre"},
    targets = {"*"},
    command = "silent! call mkdir(expand('<afile>:p:h'), 'p')",
  },
  {
    events = {"BufLeave"},
    targets = {"*"},
    command = function() if can_save() then vim.cmd "silent! update" end end,
  },
  {
    events = {"BufWritePost"},
    targets = {"*"},
    modifiers = {"nested"},
    command = function()
      if core.empty(vim.bo.filetype) or fn.exists "b:ftdetect" == 1 then
        vim.cmd [[
            unlet! b:ftdetect
            filetype detect
            echom 'Filetype set to ' . &ft
          ]]
      end
    end,
  },
  {
    events = {"Syntax"},
    targets = {"*"},
    command = "if 5000 < line('$') | syntax sync minlines=200 | endif",
  },
})
