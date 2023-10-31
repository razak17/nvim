if not rvim or rvim.none then return end

local settings, highlight = rvim.filetype_settings, rvim.highlight
local cmd, api, opt_l = vim.cmd, vim.api, vim.opt_local

vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')

settings({
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
    mappings = {
      {
        'n',
        'dd',
        rvim.list.qf.delete,
        { buffer = 0, desc = 'delete current quickfix entry' },
      },
      {
        'v',
        'd',
        rvim.list.qf.delete,
        { buffer = 0, desc = 'delete selected quickfix entry' },
      },
      {
        'n',
        'w',
        function()
          local success, picker = pcall(require, 'window-picker')
          if not success then
            vim.notify('window-picker is not installed', vim.log.levels.ERROR)
            return
          end
          local picked_window_id = picker.pick_window()
          if picked_window_id then
            local qf_list = vim.fn.getqflist()
            local line = api.nvim_win_get_cursor(0)
            local qf_entry = qf_list[line[1]]

            api.nvim_set_current_win(picked_window_id)
            cmd.edit(qf_entry.text)
          end
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
  oil = {
    opt = {
      conceallevel = 3,
      concealcursor = 'n',
      list = false,
      wrap = false,
      signcolumn = 'no',
    },
    function()
      if not rvim.is_available('oil.nvim') then return end

      local oil = require('oil')
      local function find_files()
        local dir = oil.get_current_dir()
        if vim.api.nvim_win_get_config(0).relative ~= '' then
          vim.api.nvim_win_close(0, true)
        end
        require('fzf-lua').files({ cwd = dir, hidden = true })
      end

      local function livegrep()
        local dir = oil.get_current_dir()
        if vim.api.nvim_win_get_config(0).relative ~= '' then
          vim.api.nvim_win_close(0, true)
        end
        require('telescope.builtin').live_grep({ cwd = dir })
      end
      map('n', '<leader>ff', find_files, { desc = '[F]ind [F]iles in dir' })
      map('n', '<leader>fg', livegrep, { desc = '[F]ind by [G]rep in dir' })
      vim.api.nvim_buf_create_user_command(
        0,
        'Save',
        function(params) oil.save({ confirm = not params.bang }) end,
        {
          desc = 'Save oil changes with a preview',
          bang = true,
        }
      )
      vim.api.nvim_buf_create_user_command(
        0,
        'EmptyTrash',
        function(params) oil.empty_trash() end,
        {
          desc = 'Empty the trash directory',
        }
      )
      vim.api.nvim_buf_create_user_command(
        0,
        'OpenTerminal',
        function(params) require('oil.adapters.ssh').open_terminal() end,
        {
          desc = 'Open the debug terminal for ssh connections',
        }
      )
    end,
  },
  typescript = {
    bo = { textwidth = 100 },
    opt = { spell = true },
  },
  typescriptreact = {
    bo = { textwidth = 100 },
    opt = { spell = true },
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
