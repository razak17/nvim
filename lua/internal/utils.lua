local fn = vim.fn
local api = vim.api
local fmt = string.format

local M = {}

local ts_playground_loaded, ts_hl_info

function M.command(args)
  local nargs = args.nargs or 0
  local name = args[1]
  local rhs = args[2]
  local types = (args.types and type(args.types) == "table") and
                    table.concat(args.types, " ") or ""

  if type(rhs) == "function" then
    local fn_id = r17._create(rhs)
    rhs = string.format("lua as._execute(%d%s)", fn_id,
                        nargs > 0 and ", <f-args>" or "")
  end

  vim.cmd(string.format("command! -nargs=%s %s %s %s", nargs, types, name, rhs))
end

-----------------------------------------------------------------------------//
-- CREDIT: @Cocophon
-- This function allows you to see the syntax highlight token of the cursor word and that token's links
---> https://github.com/cocopon/pgmnt.vim/blob/master/autoload/pgmnt/dev.vim
-----------------------------------------------------------------------------//
local function hi_chain(syn_id)
  local name = fn.synIDattr(syn_id, "name")
  local names = {}
  table.insert(names, name)
  local original = fn.synIDtrans(syn_id)
  if syn_id ~= original then
    table.insert(names, fn.synIDattr(original, "name"))
  end

  return names
end

function M.token_inspect()
  if not ts_playground_loaded then
    ts_playground_loaded, ts_hl_info = pcall(require,
                                             "nvim-treesitter-playground.hl-info")
  end
  if vim.tbl_contains(M.get_filetypes(), vim.bo.filetype) then
    ts_hl_info.show_hl_captures()
  else
    local syn_id = fn.synID(fn.line("."), fn.col("."), 1)
    local names = hi_chain(syn_id)
    r17.echomsg(fn.join(names, " -> "))
  end
end

function M.get_filetypes()
  vim.cmd [[packadd nvim-treesitter]]
  local parsers = require("nvim-treesitter.parsers")
  local configs = parsers.get_parser_configs()
  return vim.tbl_map(function(ft)
    return configs[ft].filetype or ft
  end, parsers.available_parsers())
end

-- Toggle list
function M.toggle_list(prefix)
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, {filewinid = 0})
    local is_loc_list = location_list.filewinid > 0
    if vim.bo[buf].filetype == "qf" or is_loc_list then
      fn.execute(prefix .. "close")
      return
    end
  end
  if prefix == "l" and vim.tbl_isempty(fn.getloclist(0)) then
    fn["utils#message"]("Location List is Empty.", "Title")
    return
  end

  local winnr = fn.winnr()
  fn.execute(prefix .. "open")
  if fn.winnr() ~= winnr then
    vim.cmd [[wincmd p]]
  end
end

function M.open_link()
  local file = fn.expand("<cfile>")
  if fn.isdirectory(file) > 0 then
    vim.cmd("edit " .. file)
  else
    fn.jobstart({vim.g.open_command, file}, {detach = true})
  end
end

function M.open_file_or_create_new()
  local path = fn.expand("<cfile>")
  if not path or path == "" then
    return false
  end

  -- TODO handle terminal buffers

  if pcall(vim.cmd, "norm!gf") then
    return true
  end

  local answer = fn.input("Create a new file, (Y)es or (N)o? ")
  if not answer or string.lower(answer) ~= "y" then
    return vim.cmd "redraw"
  end
  vim.cmd "redraw"
  local new_path = fn.fnamemodify(fn.expand("%:p:h") .. "/" .. path, ":p")
  local ext = fn.fnamemodify(new_path, ":e")

  if ext and ext ~= "" then
    return vim.cmd("edit " .. new_path)
  end

  local suffixes = fn.split(vim.bo.suffixesadd, ",")

  for _, suffix in ipairs(suffixes) do
    if fn.filereadable(new_path .. suffix) then
      return vim.cmd("edit " .. new_path .. suffix)
    end
  end

  return vim.cmd("edit " .. new_path .. suffixes[1])
end
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/tmux.lua
function M.on_enter()
  local session = fn.fnamemodify(vim.loop.cwd(), ":t") or "Neovim"
  local window_title = session
  window_title = fmt("%s", session)
  fn.jobstart(fmt("tmux rename-window '%s'", window_title))
end

function M.on_leave()
  fn.jobstart("tmux set-window-option automatic-rename on")
end

-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
function M.rename(name)
  local curfilepath = vim.fn.expand("%:p:h")
  local newname = curfilepath .. "/" .. name
  vim.api.nvim_command(" saveas " .. newname)
end

function M.TrimWhitespace()
  vim.api.nvim_exec([[
    let bsave = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(bsave)
  ]], false)
end

function M.EmptyRegisters()
  vim.api.nvim_exec([[
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
  ]], false)
end

function M.OpenTerminal()
  vim.cmd("split term://zsh")
  vim.cmd("resize 10")
end

function M.TurnOnGuides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = false
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

function M.TurnOffGuides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = true
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.o.laststatus = 0
  vim.o.showtabline = 0
end

function M.global_cmd(name, func)
  vim.cmd('command! -nargs=0 ' .. name .. ' call v:lua.' .. func .. '()')
end

function M.map(bufnr, mode, key, command, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_buf_set_keymap(bufnr, mode, key, command, options)
end

function M.buf_map(bufnr, key, command, opts)
  M.map(bufnr, 'n', key, ":" .. command .. "<CR>", opts)
end

function M.buf_cmd_map(bufnr, key, command, opts)
  M.map(bufnr, 'n', key, "<cmd>lua " .. command .. "<CR>", opts)
end

function M.nvim_create_augroup(group_name, definitions)
  vim.cmd('augroup ' .. group_name)
  vim.cmd('autocmd!')
  for _, def in ipairs(definitions) do
    local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
    vim.cmd(command)
  end
  vim.cmd('augroup END')
end

return M
