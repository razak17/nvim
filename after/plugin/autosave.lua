if not ar then return end

local enabled = ar.config.plugin.extra.autosave.enable

if ar.none or not enabled then return end

local config = {
  ignored_directories = {
    '.git',
    'node_modules',
    'vendor',
    '/etc',
  },
  ignored_filetypes = {
    'neo-tree',
    'neo-tree-popup',
    'lua.luapad',
    'gitcommit',
    'NeogitCommitMessage',
    'DiffviewFiles',
  },
}

local function is_ignored_directory(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' or name:match('^%w+://') then return false end

  local path = ar.norm(vim.fn.fnamemodify(name, ':p'))
  local path_with_separators = '/' .. path .. '/'

  for _, directory in ipairs(config.ignored_directories or {}) do
    local ignored = ar.norm(directory)
    if ignored ~= '' then
      if ignored:find('/', 1, true) then
        if path == ignored or vim.startswith(path, ignored .. '/') then
          return true
        end
      elseif path_with_separators:find('/' .. ignored .. '/', 1, true) then
        return true
      end
    end
  end

  return false
end

local function can_save(buf)
  return ar.falsy(vim.bo[buf].buftype)
    and vim.bo[buf].filetype ~= ''
    and vim.bo[buf].modifiable
    and not vim.bo[buf].readonly
    and not vim.tbl_contains(config.ignored_filetypes, vim.bo[buf].filetype)
    and not is_ignored_directory(buf)
    and ar.config.plugin.extra.autosave
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
