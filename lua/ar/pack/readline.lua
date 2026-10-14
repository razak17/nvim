if not ar.get_plugin_cond('vim-rsi', ar.plugins.coding) then return end

ar.pack.add({
  src = 'https://github.com/tpope/vim-rsi',
  event = 'InsertEnter',
})
