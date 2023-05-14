if not rvim then return end

local settings, highlight = rvim.filetype_settings, rvim.highlight
local cmd, api, opt_l = vim.cmd, vim.api, vim.opt_local

local function add_quotes_after_equals()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }
  local node = vim.treesitter.get_node({ pos = left_of_cursor_range })
  local nodes_active_in = { 'attribute_name', 'directive_argument', 'directive_name', 'property_identifier' }
  if not node or not vim.tbl_contains(nodes_active_in, node:type()) then return '=' end
  return '=""<left>'
end

settings({
  [{ 'astro', 'svelte' }] = {
    function() map('i', '=', add_quotes_after_equals, { expr = true, buffer = 0 }) end,
  },
  ['dap-repl'] = {
    opt = {
      buflisted = false,
      winfixheight = true,
      signcolumn = 'yes:2',
    },
  },
  [{ 'gitcommit', 'gitrebase' }] = {
    bo = { bufhidden = 'delete' },
    opt = {
      list = false,
      spell = true,
      spelllang = { 'en_gb', 'programming' },
    },
  },
  [{ 'rust', 'org' }] = {
    opt = { spell = true },
  },
  chatgpt = {
    function() vim.treesitter.language.register('markdown', 'chatgpt') end,
  },
  graphql = {
    opt = {
      formatoptions = vim.opt.formatoptions:remove('t'),
      iskeyword = vim.opt.iskeyword:append('$,@-@'),
    },
  },
  html = {
    bo = {
      tabstop = 2,
      softtabstop = 2,
      shiftwidth = 2,
    },
    opt = {
      matchpairs = vim.opt.matchpairs:append('<:>'),
      indentkeys = vim.opt.indentkeys:remove('*<Return>'),
    },
    function()
      cmd([[setlocal tw=120 linebreak textwidth=0]]) -- Make lines longer, and don't break them automatically
      map('i', '=', add_quotes_after_equals, { expr = true, buffer = 0 })
    end,
  },
  httpResult = {
    function()
      api.nvim_create_autocmd('BufWinEnter', {
        buffer = 0,
        command = 'wincmd L | vertical resize 80',
      })
    end,
  },
  javascript = {
    opt = { spell = true },
  },
  jsonc = {
    function()
      local extension = vim.fn.expand('%:e')
      if extension == 'jsonschema' then
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
      end
    end,
  },
  NeogitCommitMessage = {
    opt = {
      list = false,
      spell = true,
      spelllang = { 'en_gb', 'programming' },
    },
    plugins = {
      cmp = function(cmp)
        cmp.setup.filetype('NeogitCommitMessage', {
          sources = {
            { name = 'git', group_index = 1 },
            { name = 'luasnip', group_index = 1 },
            { name = 'dictionary', group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
    },
    function()
      vim.schedule(function()
        -- Schedule this call rvim highlights are not set correctly if there is not a delay
        highlight.set_winhl('gitcommit', 0, { { VirtColumn = { fg = { from = 'Variable' } } } })
      end)
      vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')
    end,
  },
  netrw = {
    g = {
      netrw_liststyle = 3,
      netrw_banner = 0,
      netrw_browse_split = 0,
      netrw_winsize = 25,
      netrw_altv = 1,
      netrw_fastbrowse = 0,
    },
    bo = { bufhidden = 'wipe' },
    mappings = {
      { 'n', 'q', '<Cmd>q<CR>' },
      { 'n', 'l', '<CR>' },
      { 'n', 'h', '<CR>' },
      { 'n', 'o', '<CR>' },
    },
  },
  qf = {
    opt = {
      wrap = false,
      number = false,
      signcolumn = 'yes',
      buflisted = false,
      winfixheight = true,
    },
    mappings = {
      { 'n', 'dd', rvim.list.qf.delete, { buffer = 0, desc = 'delete current quickfix entry' } },
      { 'v', 'd', rvim.list.qf.delete, { buffer = 0, desc = 'delete selected quickfix entry' } },
      { 'n', 'H', ':colder<CR>', { buffer = 0 } },
      { 'n', 'L', ':cnewer<CR>', { buffer = 0 } },
    },
    function()
      -- force quickfix to open beneath all other splits
      cmd.wincmd('J')
      rvim.adjust_split_height(3, 10)
    end,
  },
  typescript = {
    bo = { textwidth = 100 },
    opt = { spell = true },
  },
  typescriptreact = {
    bo = { textwidth = 100 },
    opt = { spell = true },
    function() map('i', '=', add_quotes_after_equals, { expr = true, buffer = 0 }) end,
  },
  vim = {
    bo = { syntax = 'off' },
    wo = { foldmethod = 'marker' },
    opt = {
      spell = true,
      iskeyword = vim.opt.iskeyword:append(':,#'),
    },
    function()
      vim.schedule(function() opt_l.syntax = 'off' end) -- FIXME: if the syntax isn't delayed it still gets enabled
    end,
  },
  yaml = {
    opt = {
      foldlevel = 99,
      iskeyword = vim.opt.iskeyword:append('-,$,#'),
      indentkeys = vim.opt.indentkeys:remove('<:>'),
    },
  },
})
