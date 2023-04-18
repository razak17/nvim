if not rvim then return end
local settings, highlight = rvim.filetype_settings, rvim.highlight
local cmd, fn, api, opt_l, fmt = vim.cmd, vim.fn, vim.api, vim.opt_local, string.format

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
      spelllang = 'en_gb',
    },
  },
 chatgpt = {
    function() vim.treesitter.language.register('markdown', 'chatgpt') end,
  },
  go = {
    opt = {
      tabstop = 4,
      shiftwidth = 4,
      expandtab = false,
      iskeyword = opt_l.iskeyword:append('-'),
    },
    function()
      require('which-key').register({ ['<localleader>g'] = { name = 'Gopher' } })
      local function with_desc(desc) return { buffer = 0, desc = fmt('gopher: %s', desc) } end
      map('n', '<localleader>gb', '<Cmd>GoBuild<CR>', with_desc('build'))
      map('n', '<localleader>gfs', '<Cmd>GoFillStruct<CR>', with_desc('fill struct'))
      map('n', '<localleader>gfp', '<Cmd>GoFixPlurals<CR>', with_desc('fix plurals'))
      map('n', '<localleader>gie', '<Cmd>GoIfErr<CR>', with_desc('if err'))
    end,
  },
  graphql = {
    opt = {
      formatoptions = opt_l.formatoptions:remove('t'),
      iskeyword = opt_l.iskeyword:append('$,@-@'),
    },
  },
  help = {
    opt = {
      list = false,
      spell = true,
      textwidth = 78,
    },
    plugins = {
      ['virt-column'] = function(col)
        if not vim.bo.readonly then col.setup_buffer({ virtcolumn = '+1' }) end
      end,
    },
    function(args)
      local opts = { buffer = args.buf }
      -- if this a vim help file create mappings to make navigation easier otherwise enable preferred editing settings
      if vim.startswith(fn.expand('%'), vim.env.VIMRUNTIME) or vim.bo.readonly then
        opt_l.spell = false
        api.nvim_create_autocmd('BufWinEnter', { buffer = 0, command = 'wincmd L | vertical resize 80' })
        -- https://vim.fandom.com/wiki/Learn_to_use_help
        map('n', '<CR>', '<C-]>', opts)
        map('n', '<BS>', '<C-T>', opts)
      else
        map('n', '<leader>ml', 'maGovim:tw=78:ts=8:noet:ft=help:norl:<esc>`a', opts)
      end
    end,
  },
  html = {
    bo = {
      tabstop = 2,
      softtabstop = 2,
      shiftwidth = 2,
    },
    opt = {
      matchpairs = opt_l.matchpairs:append('<:>'),
      indentkeys = opt_l.indentkeys:remove('*<Return>'),
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
  json = {
    bo = {
      autoindent = true,
      expandtab = true,
      formatoptions = 'tcq2l',
      shiftwidth = 2,
      softtabstop = 2,
      tabstop = 2,
    },
    wo = {
      conceallevel = 0,
      foldmethod = 'syntax',
    },
    function()
      if fn.expand('%:t') ~= 'package.json' then return end
      require('which-key').register({ ['<localleader>'] = { p = { name = 'Package Info' } } })
      local function with_desc(desc) return { buffer = 0, desc = fmt('package-info: %s', desc) } end
      local package_info = require('package-info')
      map('n', '<localleader>pt', package_info.toggle, with_desc('toggle'))
      map('n', '<localleader>pu', package_info.update, with_desc('update'))
      map('n', '<localleader>pd', package_info.delete, with_desc('delete'))
      map('n', '<localleader>pi', package_info.install, with_desc('install new'))
      map('n', '<localleader>pc', package_info.change_version, with_desc('package-info: change version'))
    end,
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
  lua = {
    bo = { textwidth = 120 },
    opt = {
      spell = true,
      spelllang = 'en_gb',
      spellfile = opt_l.spellfile:prepend(join_paths(vim.fn.stdpath('config'), 'spell', 'lua.utf-8.add')),
      iskeyword = opt_l.iskeyword:append('-'),
    },
  },
  markdown = {
    opt = { spell = true },
    plugins = {
      cmp = function(cmp)
        cmp.setup.filetype('markdown', {
          sources = {
            -- { name = 'dictionary', group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'emoji', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
    },
    mappings = {
      { 'n', '<localleader>P', '<Plug>MarkdownPreviewToggle', desc = 'markdown preview' },
    },
    function()
      vim.b.formatting_disabled = not vim.startswith(fn.expand('%'), vim.g.projects_dir)
      cmd.iabbrev(':tup:', '👍')
      cmd.iabbrev(':tdo:', '👎')
      cmd.iabbrev(':smi:', '😊')
      cmd.iabbrev(':sad:', '😔')
    end,
  },
  NeogitCommitMessage = {
    opt = {
      list = false,
      spell = true,
      spelllang = 'en_gb',
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
  python = {
    bo = {
      tabstop = 4,
      softtabstop = 4,
      shiftwidth = 4,
    },
    opt = {
      spell = true,
      iskeyword = opt_l.iskeyword:append('"'),
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
      { 'n', 'dd', rvim.list.qf.delete, desc = 'delete current quickfix entry' },
      { 'v', 'd', rvim.list.qf.delete, desc = 'delete selected quickfix entry' },
      { 'n', 'H', ':colder<CR>' },
      { 'n', 'L', ':cnewer<CR>' },
    },
    function()
      -- force quickfix to open beneath all other splits
      cmd.wincmd('J')
      rvim.adjust_split_height(3, 10)
    end,
  },
  [{ 'rust', 'org' }] = {
    opt = { spell = true },
  },
  toml = {
    function()
      if fn.expand('%:t') ~= 'Cargo.toml' then return end
      require('which-key').register({ ['<localleader>c'] = { name = 'Crates' } })
      local function with_desc(desc) return { buffer = 0, desc = fmt('crates: %s', desc) } end
      local crates = require('crates')
      map('n', '<localleader>ct', crates.toggle, with_desc('toggle'))
      map('n', '<localleader>cu', crates.update_crate, with_desc('update'))
      map('n', '<localleader>cU', crates.upgrade_crate, with_desc('upgrade'))
      map('n', '<localleader>ca', crates.update_all_crates, with_desc('update all'))
      map('n', '<localleader>cA', crates.upgrade_all_crates, with_desc('upgrade all'))
      map('n', '<localleader>ch', crates.open_homepage, with_desc('open home'))
      map('n', '<localleader>cr', crates.open_repository, with_desc('open repo'))
      map('n', '<localleader>cd', crates.open_documentation, with_desc('open doc'))
      map('n', '<localleader>cp', crates.open_crates_io, with_desc('open crates.io'))
      map('n', '<localleader>ci', crates.show_popup, with_desc('info'))
      map('n', '<localleader>cv', crates.show_versions_popup, with_desc('versions'))
      map('n', '<localleader>cf', crates.show_features_popup, with_desc('features'))
      map('n', '<localleader>cD', crates.show_dependencies_popup, with_desc('dependencies'))
    end,
  },
  [{ 'typescript', 'typescriptreact' }] = {
    bo = { textwidth = 100 },
    opt = { spell = true },
  },
  vim = {
    bo = { syntax = 'off' },
    wo = { foldmethod = 'marker' },
    opt = {
      spell = true,
      iskeyword = opt_l.iskeyword:append(':,#'),
    },
    function() -- TODO: if the syntax isn't delayed it still gets enabled
      vim.schedule(function() vim.bo.syntax = 'off' end)
    end,
  },
  yaml = {
    opt = {
      foldlevel = 99,
      iskeyword = opt_l.iskeyword:append('-,$,#'),
      indentkeys = opt_l.indentkeys:remove('<:>'),
    },
  },
})
