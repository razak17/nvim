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
  -- Reload vim config automatically
  {"BufWritePost", [[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]]},
  -- Reload Vim script automatically if setlocal autoread
  {
    "BufWritePost,FileWritePost",
    "*.vim",
    [[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]]
  },
  -- Disable swap/undo/viminfo/shada files in temp directories or shm
  {
    "BufNewFile,BufReadPre",
    "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim",
    "setlocal noswapfile noundofile nobackup nowritebackup viminfo= shada="
  },
  {"BufLeave", "*", "silent! update"},
  {"BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile"},
  {"BufWritePre", "MERGE_MSG", "setlocal noundofile"},
  {"BufEnter,WinEnter,InsertLeave", "*", "set cursorline"},
  {"BufLeave,WinLeave,InsertEnter", "*", "set nocursorline"},
  {"BufWritePre", "*", ":call autocmds#TrimWhitespace()"},
  {"BufWritePre", "*.tmp,*.bak", "setlocal noundofile"},
  {"BufEnter", "*", "set fo-=cro"},
  -- TODO
  -- {"BufEnter,CursorMoved,CursorMovedI,WinEnter,CompleteDone,InsertEnter,InsertLeave",
  --   "*",
  --   "lua require'modules.lang.utils'.ts_virt_text()"
  -- },
  -- {"BufEnter,CursorMoved,CursorMovedI,WinEnter,CompleteDone,InsertEnter,InsertLeave",
  --   "*",
  --   "lua require'modules.lang.utils'.ts_hl_groups()"
  -- },
}

local niceties = {
  {"TextYankPost", "*", [[ silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=77})]]},
  {"Syntax", "*", [[if line('$') > 5000 | syntax sync minlines=300 | endif]]},
  {
    "BufWritePost",
    "*",
    [[nested  if &l:filetype ==# '' || exists('b:ftdetect') | unlet! b:ftdetect | filetype detect | endif]]
  },
  -- Remember line number
  {
    "BufReadPost",
    "*",
    [[if &ft !~# 'commit' && ! &diff && line("'\"") >= 1 && line("'\"") <= line("$") | execute 'normal! g`"zvzz' | endif]]
  }
}

local win = {
  -- {"TermOpen", "*", "startinsert"},
  -- Equalize window dimensions when resizing vim window
  {"VimResized", "*", [[tabdo wincmd =]]},
  -- Force write shada on leaving nvim
  {"VimLeave", "*", "wshada!"},
  -- Highlight current line only on focused window
  {"WinEnter,BufEnter,InsertLeave", "*", [[if ! &cursorline && &filetype !~# '^\(dashboard\|telescope_\)' && ! &pvw | setlocal cursorline | endif]]};
  {"WinLeave,BufLeave,InsertEnter", "*", [[if &cursorline && &filetype !~# '^\(dashboard\|telescope_\)' && ! &pvw | setlocal nocursorline | endif]]};
  -- Force write shada on leaving nvim
  {"VimLeave", "*", [[if has('nvim') | wshada! | else | wviminfo! | endif]]};
  -- Check if file changed when its window is focus, more eager than 'autoread'
  {"FocusGained", "* checktime"};
}

local ft = {
  {"FocusLost", "*", "silent! wall"},
  {"BufEnter,FocusGained", "*", "silent! checktime"},
  {"FileType", "dashboard", "set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2"};
  {"BufNewFile,BufRead","*.toml"," setf toml"},
}


local plug = {
  {"BufWritePost","*.lua","lua require('core.pack').auto_compile()"},
  {
    "InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost",
    "*.rs",
    [[ lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"}} ]]
  },
  {"BufEnter", "*", "call v:lua.WhichKey.SetKeyOnFT()"},
}

local definitions = {
  buf,
  ft,
  win,
  niceties,
  plug
}

augroups(definitions)
