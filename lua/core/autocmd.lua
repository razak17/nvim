local vim = vim
local api = vim.api

local function augroups(definitions)
  for group_name, definition in pairs(definitions) do
    api.nvim_command("augroup " .. group_name)
    api.nvim_command("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten {"autocmd", def}, " ")
      api.nvim_command(command)
    end
    api.nvim_command("augroup END")
  end
end

local buf = {
  {
    "BufWritePost,FileWritePost",
    "*.vim",
    [[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]]
  },
  {"BufLeave", "*", "silent! update"},
  {"BufWritePre", "*", ":call autocmds#TrimWhitespace()"},
  {"BufEnter,BufNewFile", "*", "set fo-=cro noshowmode"}
}

local niceties = {
  {
    "TextYankPost",
    "*",
    [[ silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=77})]]
  },
  {"Syntax", "*", [[if line('$') > 5000 | syntax sync minlines=300 | endif]]},
  {
    "BufWritePost",
    "*",
    [[nested  if &l:filetype ==# '' || exists('b:ftdetect') | unlet! b:ftdetect | filetype detect | endif]]
  },
  {
    "BufReadPost",
    "*",
    [[if &ft !~# 'commit' && ! &diff && line("'\"") >= 1 && line("'\"") <= line("$") | execute 'normal! g`"zvzz' | endif]]
  }
}

local win = {
  -- {"TermOpen", "*", "startinsert"},
  -- Equalize window dimensions when resizing vim window
  {"VimResized", "*", [[tabdo wincmd =]]}, -- Force write shada on leaving nvim
  {"VimLeave", "*", "wshada!"},
  -- Highlight current line only on focused window
  {
    "WinEnter,BufEnter,InsertLeave",
    "*",
    [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]]
  },
  {
    "WinLeave,BufLeave,InsertEnter",
    "*",
    [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]]
  },
  -- Force write shada on leaving nvim
  {"VimLeave", "*", [[if has('nvim') | wshada! | else | wviminfo! | endif]]},
  -- Check if file changed when its window is focus, more eager than 'autoread'
  {"BufEnter,FocusGained", "*", "silent! checktime"}
}

local ft = {
  -- {
  --   "FileType",
  --   "dashboard",
  --   "set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2"
  -- },
  {"FocusLost", "*", "silent! wall"},
  {
    "FileType",
    "which_key",
    "set laststatus=0 noshowmode noruler | autocmd BufLeave <buffer> set laststatus=2 ruler"
  },
  {"FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()"}
}

local definitions = {buf, ft, win, niceties}

augroups(definitions)

