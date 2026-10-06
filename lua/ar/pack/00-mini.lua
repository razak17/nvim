local minimal = ar.plugins.minimal
local coding = ar.plugins.coding

if ar.get_plugin_cond('mini.extra') then
  vim.pack.add(
    { 'https://github.com/nvim-mini/mini.extra' },
    { confirm = false }
  )
  require('mini.extra').setup()
end

if ar.get_plugin_cond('mini.hipatterns') then
  vim.pack.add(
    { 'https://github.com/nvim-mini/mini.hipatterns' },
    { confirm = false }
  )
end

if ar.get_plugin_cond('mini.bracketed', not minimal) then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add(
      { 'https://github.com/nvim-mini/mini.bracketed' },
      { confirm = false }
    )
    require('mini.bracketed').setup({ buffer = { suffix = '' } })
    loaded = true
  end

  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    once = true,
    callback = load,
  })
end

if ar.get_plugin_cond('mini.trailspace', not minimal) then
  vim.pack.add(
    { 'https://github.com/nvim-mini/mini.trailspace' },
    { confirm = false }
  )
  require('mini.trailspace').setup({})
  ar.add_to_select('command_palette', {
    ['Remove Trailing Empty Lines'] = function()
      require('mini.trailspace').trim_last_lines()
    end,
    ['Remove Trailing Spaces'] = function() require('mini.trailspace').trim() end,
  })
end

if ar.get_plugin_cond('mini.splitjoin') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add(
      { 'https://github.com/nvim-mini/mini.splitjoin' },
      { confirm = false }
    )
    require('mini.splitjoin').setup({ mappings = { toggle = '<leader>J' } })
    loaded = true
  end

  vim.keymap.set({ 'n', 'x' }, '<leader>J', function()
    load()
    local keys = vim.api.nvim_replace_termcodes('<leader>J', true, false, true)
    vim.api.nvim_feedkeys(keys, 'mi', false)
  end, { desc = 'splitjoin: toggle' })
end

if ar.get_plugin_cond('mini.comment', coding) then
  local function load()
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then return end
      vim.pack.add(
        { 'https://github.com/nvim-mini/mini.comment' },
        { confirm = false }
      )
      require('mini.comment').setup({
        options = {
          custom_commentstring = function()
            if ar.has('nvim-ts-context-commentstring') then
              return require('ts_context_commentstring.internal').calculate_commentstring()
            end
            return vim.bo.commentstring
          end,
        },
      })
    end)
  end

  if vim.v.vim_did_enter == 1 then
    load()
  else
    vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = load })
  end
end
