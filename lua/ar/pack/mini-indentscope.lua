local separators = ar.ui.icons.separators
local enabled = ar.config.ui.indentline.enable
  and ar.config.ui.indentline.variant == 'mini.indentscope'
if not ar.get_plugin_cond('mini.indentscope', enabled) then return end

local loaded = false
local function load()
  if loaded then return end
  vim.pack.add(
    { 'https://github.com/nvim-mini/mini.indentscope' },
    { confirm = false }
  )
  local opts = {
    symbol = separators.left_thin_block,
    draw = {
      delay = 100,
      priority = 2,
      animation = function(s, n) return s / n * 20 end,
    },
        -- stylua: ignore
        filetype_exclude = {
          'lazy', 'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit',
          'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline', 'undotree',
          'markdown', 'norg', 'org', 'orgagenda', 'snacks_dashboard', 'sidekick_terminal',
          '', -- for all buffers without a file type
        },
  }
  ar.highlight.plugin('mini-indentscope', {
    theme = {
      ['onedark'] = {
        { MiniIndentscopeSymbol = { link = 'IndentBlanklineContextChar' } },
        { MiniIndentscopeSymbolOff = { link = 'IndentBlanklineChar' } },
      },
      ['default'] = {
        { MiniIndentscopeSymbol = { link = 'NonText' } },
        { MiniIndentscopeSymbolOff = { link = 'NonText' } },
      },
    },
  })
  require('mini.indentscope').setup(opts)

  ar.augroup('MiniIndentscopeDisable', {
    event = { 'FileType' },
    desc = 'Disable indentscope for certain files',
    command = function()
      -- stylua: ignore
      local ignored_filetypes = {
        'aerial', 'dashboard', 'help', 'lazy', 'leetcode.nvim', 'mason', 'neo-tree',
        'NvimTree', 'neogitstatus', 'notify', 'startify', 'toggleterm', 'Trouble',
        'fzf', 'alpha', 'starter', 'dbout', 'neo-tree-popup', 'log', 'gitcommit', 'txt', 'git',
        'flutterToolsOutline', 'undotree', 'markdown', 'norg', 'org', 'orgagenda',
      }
      local ignored_buftypes = { 'nofile', 'terminal' }
      if
        vim.tbl_contains(ignored_filetypes, vim.bo.filetype)
        or vim.tbl_contains(ignored_buftypes, vim.bo.buftype)
      then
        vim.b.miniindentscope_disable = true
      end
    end,
  })
  loaded = true
end

if #vim.api.nvim_list_uis() > 0 then
  load()
else
  vim.api.nvim_create_autocmd('UIEnter', { once = true, callback = load })
end
