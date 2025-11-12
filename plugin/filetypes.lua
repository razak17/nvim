local enabled = ar_config.plugin.main.filetypes.enable

if not ar or ar.none or not enabled then return end

local settings, highlight = ar.filetype_settings, ar.highlight
local cmd, api, fn, opt_l = vim.cmd, vim.api, vim.fn, vim.opt_local

vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')

settings({
  [{ 'bash', 'sh' }] = {
    opt = {
      list = false,
      spell = true,
      spelllang = { 'en', 'programming' },
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
      spelllang = { 'en', 'programming' },
    },
    function() vim.bo.commentstring = '; %s' end,
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
      spelllang = { 'en', 'programming' },
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
  },
  text = {
    bo = { textwidth = 78 },
    wo = { spell = false },
  },
  typst = {
    function()
      api.nvim_create_user_command('OpenPdf', function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if filepath:match('%.typ$') then
          local pdf_path = filepath:gsub('%.typ$', '.pdf')
          ar.open(pdf_path)
        end
      end, {})
    end,
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
    end,
  },
})
