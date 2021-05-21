local M = {}

function M.OpenTerminal()
  vim.api.nvim_command("split term://zsh")
  vim.api.nvim_command("resize 10")
end

function M.TurnOnGuides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

function M.TurnOffGuides()
  vim.wo.number = false
  vim.wo.relativenumber = false
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
  vim.api.nvim_command('augroup ' .. group_name)
  vim.api.nvim_command('autocmd!')
  for _, def in ipairs(definitions) do
    local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
    vim.api.nvim_command(command)
  end
  vim.api.nvim_command('augroup END')
end

return M
