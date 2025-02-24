local enabled = ar_config.plugin.main.filetypes.enable

if not ar or ar.none or not enabled then return end

local settings, highlight = ar.filetype_settings, ar.highlight
local cmd, api, fn, opt_l = vim.cmd, vim.api, vim.fn, vim.opt_local
local is_available = ar.is_available

vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')

settings({
  [{ 'bash', 'sh' }] = {
    opt = {
      list = false,
      spell = true,
      spelllang = { 'en_gb', 'programming' },
    },
    function()
      -- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L141
      local function run_bash_file()
        if vim.env.TMUX == nil then
          vim.notify('Not in tmux.')
          return
        end
        local file = fn.expand('%')
        local first_line = fn.getline(1)
        if string.match(first_line, '^#!/') then
          local escaped_file = fn.shellescape(file)
          cmd(
            'silent !tmux split-window -h -Z \'bash -c "'
              .. escaped_file
              .. '; echo; echo Press any key to exit...; read -n 1; exit"\''
          )
        else
          cmd("echo 'Not a script. Shebang line not found.'")
        end
      end

      map(
        'n',
        '<leader>rr',
        run_bash_file,
        { desc = 'execute file', buffer = 0 }
      )

      if is_available('LuaSnip') and is_available('snips') then
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
      map('i', 't', require('ar.async_func').add, { buffer = true })

      if is_available('LuaSnip') and is_available('snips') then
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
      if is_available('LuaSnip') and is_available('snips') then
        local ls = require('luasnip')
        local jsr = require('snips.typescriptreact')

        local s = ls.s

        local snippets = function()
          return {
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
      map(
        'n',
        '<localleader>lu',
        toggle_use_client,
        { buffer = 0, desc = 'toggle use client' }
      )
    end,
  },
  [{ 'typescript', 'typescriptreact' }] = {
    function()
      local interface_to_type =
        require('ar.interface_to_type').interface_to_type
      map('i', 't', require('ar.async_func').add, { buffer = true })
      map('n', '<leader><leader>ti', interface_to_type, { buffer = true })

      api.nvim_create_user_command('InterfaceToType', interface_to_type, {})

      ar.add_to_select_menu('command_palette', {
        ['Interface to Type'] = interface_to_type,
      })
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
            { name = 'buffer', group_index = 1 },
            { name = 'spell', group_index = 1 },
          },
        })
      end,
    },
    function()
      vim.schedule(function()
        -- Schedule this call as highlights are not set correctly if there is not a delay
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
  org = {
    opt = { spell = true },
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
      { 'n', 'dd', '<Cmd>QfListDelete<CR>', { buffer = 0, desc = 'delete current quickfix entry' } },
      { 'x', 'd', ':QfListDelete<CR>', { buffer = 0, desc = 'delete selected quickfix entry' } },
      {
        'n',
        'w',
        function()
          local qf_list = fn.getqflist()
          local line = api.nvim_win_get_cursor(0)
          local qf_entry = qf_list[line[1]]
          ar.open_with_window_picker(function()
            api.nvim_set_current_buf(qf_entry.bufnr)
          end
          )
        end,
        { buffer = 0, desc = 'open entry with window picker' },
      },
      { 'n', 'H', ':colder<CR>', { buffer = 0 } },
      { 'n', 'L', ':cnewer<CR>', { buffer = 0 } },
    },
    function()
      -- force quickfix to open beneath all other splits
      cmd.wincmd('J')
      ar.adjust_split_height(5, 10)
      -- stylua: ignore
      api.nvim_buf_create_user_command(0, 'QfListDelete', ar.list.qf.delete, { range = true })
    end,
  },
  rust = {
    opt = { spell = true },
    plugins = {
      cmp = function(cmp)
        cmp.setup.filetype('norg', {
          sorting = {
            -- deprioritize `.box`, `.mut`, etc.
            require('cmp-rust').deprioritize_postfix,
            -- deprioritize `Borrow::borrow` and `BorrowMut::borrow_mut`
            require('cmp-rust').deprioritize_borrow,
            -- deprioritize `Deref::deref` and `DerefMut::deref_mut`
            require('cmp-rust').deprioritize_deref,
            -- deprioritize `Into::into`, `Clone::clone`, etc.
            require('cmp-rust').deprioritize_common_traits,
          },
        })
      end,
    },
    function()
      if is_available('LuaSnip') and is_available('snips') then
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

      if is_available('LuaSnip') and is_available('snips') then
        local ls = require('luasnip')
        local kubernetes = require('snips.kubernetes')

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
