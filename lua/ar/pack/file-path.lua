local coding = ar.plugins.coding

if ar.get_plugin_cond('yank-path.nvim') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add(
      { 'https://github.com/ywpkwon/yank-path.nvim' },
      { confirm = false }
    )
    require('yank-path').setup({ default_mapping = false })
    loaded = true
  end

  ar.pack.cmd('YankPath', load)
  map('n', '<leader><localleader>fo', '<Cmd>YankPath<CR>', {
    desc = 'yank-path: file path',
  })
end

if ar.get_plugin_cond('nvim-genghis', coding) then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add(
      { 'https://github.com/chrisgrieser/nvim-genghis' },
      { confirm = false }
    )
    loaded = true
  end

  vim.g.whichkey_add_spec({ '<leader><localleader>f', group = 'Path' })

  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    once = true,
    callback = load,
  })

  local mappings = {
    { 'p', 'copyFilepath', 'yank filepath' },
    { 'f', 'copyFilename', 'yank filename' },
    { 'r', 'renameFile', 'rename file' },
    { 'm', 'moveAndRenameFile', 'move and rename' },
    { 'n', 'createNewFile', 'create new file' },
    { 'D', 'duplicateFile', 'duplicate current file' },
  }

  for _, mapping in ipairs(mappings) do
    map('n', '<leader><localleader>f' .. mapping[1], function()
      load()
      require('genghis')[mapping[2]]()
    end, { desc = 'genghis: ' .. mapping[3] })
  end

  map('n', '<leader><localleader>fd', function()
    if vim.fn.confirm('Delete file?', '&Yes\n&No') == 1 then
      load()
      require('genghis').trashFile()
    end
  end, { desc = 'genghis: move to trash' })
end
