if not ar then return end

local enabled = ar.config.plugin.core.pack.enable

if not ar or ar.none or not enabled then return end

vim.cmd('packadd nvim.undotree')
vim.cmd('packadd nvim.difftool')

local function undo()
  require('undotree').open({
    command = math.floor(vim.api.nvim_win_get_width(0) / 3) .. 'vnew',
  })
end

map('n', '<leader><leader>U', undo, { desc = 'undotree toggle' })
