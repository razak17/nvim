local M = {}
local fn = vim.fn
local fmt = string.format

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
