local coding = ar.plugins.coding

if not ar.get_plugin_cond('vim-rsi', coding) then return end

local function load()
  vim.pack.add({
    'https://github.com/tpope/vim-rsi',
  }, { confirm = false })
end

vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = load,
})
