local save_excluded = {
  'neo-tree',
  'neo-tree-popup',
  'lua.luapad',
  'gitcommit',
  'NeogitCommitMessage',
  'DiffviewFiles',
}

local function can_save(buf)
  return ar.falsy(vim.bo[buf].buftype)
    and vim.bo[buf].filetype ~= ''
    and vim.bo[buf].modifiable
    and not vim.bo[buf].readonly
    and not vim.tbl_contains(save_excluded, vim.bo[buf].filetype)
    and ar.config.autosave.enable
  -- and ar.kitty_scrollback.enable
end

ar.augroup('Autosave', {
  event = { 'FocusLost', 'InsertLeave', 'TextChanged' },
  command = function(args)
    if not vim.bo[args.buf].modified then return end
    if can_save(args.buf) then
      vim.api.nvim_buf_call(args.buf, function() vim.cmd('silent! update') end)
    end
  end,
})
