local fn = vim.fn
local api = vim.api

local M = {}

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

local ts_playground_loaded, ts_hl_info
function M.inspect_token()
  if not ts_playground_loaded then
    ts_playground_loaded, ts_hl_info = pcall(require, "nvim-treesitter-playground.hl-info")
  end
  if vim.tbl_contains(rvim.treesitter.get_filetypes(), vim.bo.filetype) then
    ts_hl_info.show_hl_captures()
  else
    local syn_id = fn.synID(fn.line ".", fn.col ".", 1)
    local names = hi_chain(syn_id)
    rvim.echomsg(fn.join(names, " -> "))
  end
end

function M.save_and_notify()
  vim.cmd "silent write"
  vim.notify("Saved " .. vim.fn.expand "%:t", { timeout = 1000 })
end

function M.open_file_or_create_new()
  local path = fn.expand "<cfile>"
  if not path or path == "" then
    return false
  end

  -- TODO handle terminal buffers

  if pcall(vim.cmd, "norm!gf") then
    return true
  end

  local answer = fn.input "Create a new file, (Y)es or (N)o? "
  if not answer or string.lower(answer) ~= "y" then
    return vim.cmd "redraw"
  end
  vim.cmd "redraw"
  local new_path = fn.fnamemodify(fn.expand "%:p:h" .. "/" .. path, ":p")
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

function M.open_link()
  local file = fn.expand "<cfile>"
  if fn.isdirectory(file) > 0 then
    vim.cmd("edit " .. file)
  else
    fn.jobstart({ vim.g.open_command, file }, { detach = true })
  end
end

function M.toggle_list(prefix)
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, { filewinid = 0 })
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

function M.ColorMyPencils()
  vim.cmd [[ hi! ColorColumn guibg=#aeacec ]]
  vim.cmd [[ hi! Normal ctermbg=none guibg=none ]]
  vim.cmd [[ hi! SignColumn ctermbg=none guibg=none ]]
  vim.cmd [[ hi! LineNr guifg=#4dd2dc ]]
  vim.cmd [[ hi! CursorLineNr guifg=#f0c674 ]]
  vim.cmd [[ hi! TelescopeBorder guifg=#ffff00 guibg=#ff0000 ]]
  vim.cmd [[ hi! WhichKeyGroup guifg=#4dd2dc ]]
  vim.cmd [[ hi! WhichKeyDesc guifg=#4dd2dc  ]]
end

function M.EmptyRegisters()
  vim.api.nvim_exec(
    [[
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
  ]],
    false
  )
end

function M.OpenTerminal()
  vim.cmd "split term://zsh"
  vim.cmd "resize 10"
end

function M.TurnOnGuides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

function M.TurnOffGuides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.o.laststatus = 0
  vim.o.showtabline = 0
end

-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
function M.rename(name)
  local curfilepath = vim.fn.expand "%:p:h"
  local newname = curfilepath .. "/" .. name
  vim.api.nvim_command(" saveas " .. newname)
end

function M.load_conf(dir, name)
  local module_dir = string.format("modules.%s", dir)
  return require(string.format(module_dir .. ".%s", name))
end

--- Checks whether a given path exists and is a file.
--@param path (string) path to check
--@returns (bool)
function M.is_file(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "file" or false
end

return M
