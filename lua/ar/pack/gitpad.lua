if not ar.get_plugin_cond('gitpad.nvim') then return end

vim.g.whichkey_add_spec({ '<localleader>p', group = 'Pad' })
local loaded = false
local function load()
  if loaded then return end
  vim.pack.add(
    { 'https://github.com/yujinyuz/gitpad.nvim' },
    { confirm = false }
  )
  local opts = {
    title = 'Notes',
    default_text = '',
    on_attach = function(bufnr)
        -- stylua: ignore
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>wq<CR>', { noremap = true, silent = true })
    end,
  }
  ar.highlight.plugin('neogit', {
    { GitpadFloat = { inherit = 'NormalFloat' } },
    { GitpadFloatBorder = { inherit = 'FloatBorder' } },
    { GitpadFloatTitle = { inherit = 'FloatTitle' } },
  })
  require('gitpad').setup(opts)
  loaded = true
end

local mappings = {
  {
    '<localleader>pp',
    function() require('gitpad').toggle_gitpad() end,
    desc = 'gitpad: project note',
  },
  {
    '<localleader>pb',
    function() require('gitpad').toggle_gitpad_branch() end,
    desc = 'gitpad: branch note',
  },
  {
    '<localleader>pd',
    function()
      local date_filename = 'daily-' .. os.date('%Y-%m-%d.md')
      require('gitpad').toggle_gitpad({ filename = date_filename })
    end,
    desc = 'gitpad: daily note',
  },
  {
    '<localleader>pf',
    function()
      local filename = vim.fn.expand('%:p')
      if filename == '' then
        vim.notify('empty bufname')
        return
      end
      filename = vim.fn.pathshorten(filename, 2) .. '.md'
      require('gitpad').toggle_gitpad({ filename = filename })
    end,
    desc = 'gitpad: file note',
  },
}
for _, mapping in ipairs(mappings) do
  vim.keymap.set('n', mapping[1], function()
    load()
    mapping[2]()
  end, { desc = mapping.desc })
end
