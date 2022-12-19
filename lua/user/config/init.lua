if not rvim then return end

vim.g.python3_host_prog = rvim.path.python3
vim.g.node_host_prog = rvim.path.node
for _, v in pairs(rvim.util.disabled_providers) do
  vim.g['loaded_' .. v .. '_provider'] = 0
end
for _, plugin in pairs(rvim.util.disabled_builtins) do
  vim.g['loaded_' .. plugin] = 1
end

if rvim.ui.defer then
  vim.cmd([[syntax off]])
  vim.cmd([[filetype off]])
  vim.defer_fn(
    vim.schedule_wrap(function()
      vim.defer_fn(function()
        vim.cmd([[syntax on]])
        vim.cmd([[filetype plugin indent on]])
      end, 0)
    end),
    0
  )
end

-- NOTE: order matters
R('user.core.highlights')
R('user.core.commands')
R('user.core.packer').ensure_plugins()
R('user.core.packer').load_compile()
