if not rvim or rvim.none then return end

local settings, highlight = rvim.filetype_settings, rvim.highlight
local cmd, api, fn, opt_l = vim.cmd, vim.api, vim.fn, vim.opt_local

vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')

settings({
  bash = {
    opt = { spell = true },
    function()
      if rvim.is_available('LuaSnip') then
        local ls = require('luasnip')
        local bash = require('snips.bash')

        local s = ls.s

        ls.add_snippets('sh', {
          s('set', bash.primitives.default_flags()),
          s('f', bash.primitives.func()),
          s('v', bash.choices.variable()),
        })
      end
    end,
  },
  config = {
    bo = {
      textwidth = 0,
      wrapmargin = 0,
    },
  },
  cpp = {
    bo = {
      shiftwidth = 4,
      tabstop = 4,
      softtabstop = 4,
      commentstring = '// %s',
    },
    wo = { spell = false },
    function() cmd([[setlocal path+=/usr/include/**,/usr/local/include/**]]) end,
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
  graphql = {
    function()
      vim.opt.iskeyword:append('$,@-@')
      vim.opt.formatoptions:remove('t')
    end,
  },
  html = {
    bo = {
      tabstop = 2,
      softtabstop = 2,
      shiftwidth = 2,
    },
    function()
      cmd([[setlocal tw=120 linebreak textwidth=0]]) -- Make lines longer, and don't break them automatically

      vim.opt.matchpairs:append('<:>')
      vim.opt.indentkeys:remove('*<Return>')
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
  [{ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }] = {
    bo = { textwidth = 100 },
    opt = { spell = true },
    function()
      if rvim.is_available('LuaSnip') then
        local ls = require('luasnip')
        local js = require('snips.javascript')

        local s = ls.s
        local i = ls.insert_node

        local snippets = function()
          return {
            s('f', js.dynamic.func(), {
              stored = {
                name = i(1, 'name'),
                param = i(1),
                body = i(1),
              },
            }),
            s('o', js.choices.stdout(), {
              stored = {
                value = i(1, 'value'),
              },
            }),
            s('con', js.primitives.constructor()),
            s('c', js.primitives.class()),
          }
        end

        ls.add_snippets('javascript', snippets())
        ls.add_snippets('typescript', snippets())
        ls.add_snippets('javascriptreact', snippets())
        ls.add_snippets('typescriptreact', snippets())
      end
    end,
  },
  [{ 'javascriptreact', 'typescriptreact' }] = {
    bo = { textwidth = 100 },
    opt = { spell = true },
    function()
      if rvim.is_available('LuaSnip') then
        local ls = require('luasnip')
        local jsr = require('snips.javascriptreact')

        local s = ls.s

        local snippets = function()
          return {
            s('c', jsr.primitives.component()),
            s('hs', jsr.primitives.use_state()),
            s('he', jsr.primitives.use_effect()),
          }
        end

        ls.add_snippets('javascriptreact', snippets())
        ls.add_snippets('typescriptreact', snippets())
      end

      local function toggle_use_client()
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
        if string.match(first_line, 'use client') then
          vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
        else
          vim.api.nvim_buf_set_lines(0, 0, 1, false, { '"use client";' })
        end
      end
      map('n', '<localleader>lu', toggle_use_client, { buffer = 0 })
    end,
  },
  jsonc = {
    function()
      local extension = fn.expand('%:e')
      if extension == 'jsonschema' then
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
      end
    end,
  },
  ['Neogit*'] = {
    wo = { winbar = '' },
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
            { name = 'dictionary', max_item_count = 10, group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
    },
    function()
      vim.schedule(function()
        -- Schedule this call rvim highlights are not set correctly if there is not a delay
        highlight.set_winhl(
          'gitcommit',
          0,
          { { VirtColumn = { fg = { from = 'Variable' } } } }
        )
      end)
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
    -- stylua: ignore
    mappings = {
      { 'n', 'dd', rvim.list.qf.delete, { buffer = 0, desc = 'delete current quickfix entry' } },
      { 'v', 'd', rvim.list.qf.delete, { buffer = 0, desc = 'delete selected quickfix entry' } },
      {
        'n',
        'w',
        function()
          local qf_list = fn.getqflist()
          local line = api.nvim_win_get_cursor(0)
          local qf_entry = qf_list[line[1]]
          rvim.open_with_window_picker(qf_entry.bufnr)
        end,
        { buffer = 0, desc = 'open entry with window picker' },
      },
      { 'n', 'H', ':colder<CR>', { buffer = 0 } },
      { 'n', 'L', ':cnewer<CR>', { buffer = 0 } },
    },
    function()
      -- force quickfix to open beneath all other splits
      cmd.wincmd('J')
      rvim.adjust_split_height(5, 10)
    end,
  },
  rust = {
    function()
      if rvim.is_available('LuaSnip') then
        local ls = require('luasnip')
        local rust = require('snips.rust')
        local common = require('snips.common')

        local s = ls.s

        ls.add_snippets('rust', {
          s('o', rust.dynamic.stdout()),
          s('v', rust.primitives.variable()),
          s('r', common.primitives.returns()),
          s('vec', rust.primitives.vector_struct()),
        })
      end
    end,
  },
  text = {
    bo = { textwidth = 78 },
    wo = { spell = false },
  },
  vim = {
    bo = { syntax = 'off' },
    wo = { foldmethod = 'marker' },
    opt = { spell = true },
    function()
      vim.schedule(function() opt_l.syntax = 'off' end) -- FIXME: if the syntax isn't delayed it still gets enabled
      vim.opt.iskeyword:append(':,#')
    end,
  },
  yaml = {
    opt = { foldlevel = 99 },
    function()
      vim.opt.iskeyword:append('-,$,#')
      vim.opt.indentkeys:append('<:>')

      local ls = require('luasnip')
      local kubernetes = require('snips.kubernetes')

      if rvim.is_available('LuaSnip') then
        local s = ls.s

        ls.add_snippets('yaml', {
          s('pod', kubernetes.primitives.pod()),
          s('rs', kubernetes.primitives.replicaset()),
          s('dep', kubernetes.primitives.deployment()),
          s('ser', kubernetes.primitives.service()),
        })
      end
    end,
  },
})
