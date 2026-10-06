if not require('ar.pack.telescope') then return end

local function get_cond(plugin)
  local condition = ar.config.picker.variant == 'telescope'
  if not plugin then return condition end
  return ar.get_plugin_cond(plugin, condition)
end

if get_cond('telescope-frecency.nvim') then
  vim.pack.add(
    { 'https://github.com/nvim-telescope/telescope-frecency.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  local datapath = vim.fn.stdpath('data')
  vim.g.telescope_add_extension({ 'frecency' }, opts, {
    frecency = {
      db_root = join_paths(datapath, 'databases'),
      default_workspace = 'CWD',
      show_filter_column = false,
      show_scores = true,
      show_unindexed = true,
      db_safe_mode = false,
      auto_validate = true,
      db_validate_threshold = 20,
      ignore_patterns = {
        '*/tmp/*',
        '*node_modules/*',
        '*vendor/*',
      },
      workspaces = {
        conf = vim.g.dotfiles,
        project = vim.g.projects_dir,
      },
    },
  })
  local mappings = {
    {
      '<leader>fh',
      function()
        require('telescope').extensions.frecency.frecency({
          workspace = 'CWD',
        })
      end,
      desc = 'Most (f)recently used files',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if
  ar.get_plugin_cond(
    'telescope-cmdline.nvim',
    ar.config.ui.cmdline.variant == 'telescope-cmdline'
  )
then
  vim.pack.add(
    { 'https://github.com/jonarrien/telescope-cmdline.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'cmdline' }, opts)
  local mappings = {
    { ':', '<Cmd>Telescope cmdline<CR>', desc = 'Cmdline' },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if
  ar.get_plugin_cond('smart-open.nvim', ar.config.picker.files == 'smart-open')
then
  vim.pack.add(
    { 'https://github.com/danielfalk/smart-open.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'smart_open' }, opts, {
    ['smart_open'] = {
      show_scores = true,
      ignore_patterns = {
        '*.git/*',
        '*/tmp/*',
        '*vendor/*',
        '*node_modules/*',
      },
      match_algorithm = 'fzf',
      disable_devicons = false,
    },
  })
  local mappings = {
    {
      '<C-p>',
      function()
        require('telescope').extensions.smart_open.smart_open({
          cwd_only = true,
          no_ignore = true,
          show_scores = false,
        })
      end,
      desc = 'smart open',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-file-browser.nvim') then
  vim.pack.add(
    { 'https://github.com/nvim-telescope/telescope-file-browser.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'file_browser' }, opts)
  local function get_keys()
    local function file_browser(o)
      o = vim.tbl_extend('keep', o or {}, {
        hidden = true,
        no_ignore = true,
        sort_mru = true,
        sort_lastused = true,
      })
      require('telescope').extensions.file_browser.file_browser(o)
    end

          -- stylua: ignore
          return {
            { '<leader>f,', file_browser, desc = 'file browser (root)' },
            { '<leader>f.', function() file_browser({ path = '%:p:h', select_buffer = 'true' }) end, desc = 'file browser (curr dir)', },
          }
  end
  local mappings = get_keys()
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-undo.nvim') then
  vim.pack.add(
    { 'https://github.com/debugloop/telescope-undo.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'undo' }, opts, {
    undo = {
      mappings = {
        i = {
          ['<C-a>'] = require('telescope-undo.actions').yank_additions,
          ['<C-d>'] = require('telescope-undo.actions').yank_deletions,
          ['<C-u>'] = require('telescope-undo.actions').restore,
        },
      },
    },
  })
  local mappings = {
    {
      '<leader>fu',
      function() require('telescope').extensions.undo.undo() end,
      desc = 'undo',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if
  (function() return ar.get_plugin_cond('telescope-smart-history.nvim') end)()
then
  vim.pack.add(
    { 'https://github.com/nvim-telescope/telescope-smart-history.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'smart_history' }, opts)
end

if get_cond('telescope-live-grep-args.nvim') then
  vim.pack.add({
    {
      src = 'https://github.com/nvim-telescope/telescope-live-grep-args.nvim',
      version = vim.version.range('^1.0.0'),
    },
  }, { confirm = false })
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'live_grep_args' }, opts, {
    live_grep_args = {
      auto_quoting = true,
      mappings = {
        i = {
          ['<c-y>'] = require('telescope-live-grep-args.actions').quote_prompt(),
          ['<c-i>'] = require('telescope-live-grep-args.actions').quote_prompt({
            postfix = ' --iglob ',
          }),
          ['<C-r>'] = require('telescope-live-grep-args.actions').to_fuzzy_refine,
        },
      },
    },
  })
  local function get_keys()
    local function live_grep_args()
      require('telescope').extensions.live_grep_args.live_grep_args({
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
      })
    end
    local function live_grep_args_word()
      local ok, lga_shortcuts =
        pcall(require, 'telescope-live-grep-args.shortcuts')
      if not ok then
        vim.notify('telescope-live-grep-args.nvim is not installed')
        return
      end
      lga_shortcuts.grep_word_under_cursor()
    end
    local function live_grep_args_selection()
      local ok, lga_shortcuts =
        pcall(require, 'telescope-live-grep-args.shortcuts')
      if not ok then
        vim.notify('telescope-live-grep-args.nvim is not installed')
        return
      end
      lga_shortcuts.grep_visual_selection()
    end

          -- stylua: ignore
          return {
            { '<leader>fga', live_grep_args, desc = 'live-grep-args: grep' },
            { '<leader>fgw', live_grep_args_word, desc = 'live-grep-args: word' },
            { '<leader>fgs', live_grep_args_selection, desc = 'live-grep-args: selection', mode = { 'x' } },
          }
  end
  local mappings = get_keys()
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-egrepify.nvim') then
  vim.pack.add(
    { 'https://github.com/fdschmidt93/telescope-egrepify.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'egrepify' }, opts)
  local mappings = {
    {
      '<leader>fe',
      function() require('telescope').extensions.egrepify.egrepify() end,
      desc = 'egrepify',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-helpgrep.nvim') then
  vim.pack.add(
    { 'https://github.com/catgoose/telescope-helpgrep.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'helpgrep' }, opts, {
    helpgrep = {
      ignore_paths = { vim.fn.stdpath('state') .. '/lazy/readme' },
    },
  })
  local mappings = {
    {
      '<leader>fH',
      function() require('telescope').extensions.helpgrep.helpgrep() end,
      desc = 'egrepify',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-spell-errors.nvim') then
  vim.pack.add(
    { 'https://github.com/matkrin/telescope-spell-errors.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'spell_errors' }, opts)
  local mappings = {
    {
      '<leader>fX',
      function() require('telescope').extensions.spell_errors.spell_errors() end,
      desc = 'spell errors',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('whop.nvim') then
  vim.pack.add({ 'https://github.com/biozz/whop.nvim' }, { confirm = false })
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'whop' }, opts)
  local mappings = {
    {
      '<leader>fW',
      function()
        require('telescope').extensions.whop.whop(ar.telescope.minimal_ui())
      end,
      desc = 'whop',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-directory.nvim') then
  vim.pack.add(
    { 'https://github.com/fbuchlak/telescope-directory.nvim' },
    { confirm = false }
  )
  require('telescope-directory').setup({})
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'directory' }, opts)
  local function get_keys()
    local function directory_files()
      require('telescope').extensions.directory.directory({
        feature = 'find_files',
      })
    end
    local function directory_search()
      require('telescope').extensions.directory.directory({
        feature = 'live_grep',
        feature_opts = { hidden = true, no_ignore = true },
        hidden = true,
        no_ignore = true,
      })
    end

          -- stylua: ignore
          return {
            { '<leader>fgf', directory_files, desc = 'directory for find files' },
            { '<leader>fgg', directory_search, desc = 'directory for live grep' },
          }
  end
  local mappings = get_keys()
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-git-file-history.nvim') then
  vim.pack.add(
    { 'https://github.com/isak102/telescope-git-file-history.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'git_file_history' }, opts)
  local mappings = {
    {
      '<leader>fgh',
      function()
        require('telescope').extensions.git_file_history.git_file_history()
      end,
      desc = 'git file history',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-git-branch') then
  vim.pack.add(
    { 'https://github.com/mrloop/telescope-git-branch.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'git_branch' }, opts)
  local mappings = {
    {
      mode = { 'n', 'v' },
      '<leader>gf',
      function() require('git_branch').files() end,
      desc = 'git branch',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('jsonfly.nvim') then
  vim.pack.add(
    { 'https://github.com/Myzel394/jsonfly.nvim' },
    { confirm = false }
  )
  vim.g.telescope_add_extension({ 'jsonfly' })
  local mappings = {
    {
      '<leader>fJ',
      '<Cmd>Telescope jsonfly<CR>',
      desc = 'Open json(fly)',
    },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-yaml.nvim') then
  vim.pack.add(
    { 'https://github.com/dapc11/telescope-yaml.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'telescope-yaml' }, opts)
  local mappings = {
    { '<leader>fy', '<Cmd>Telescope telescope-yaml<CR>', desc = 'yaml' },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if get_cond('telescope-heading.nvim') then
  vim.pack.add(
    { 'https://github.com/crispgm/telescope-heading.nvim' },
    { confirm = false }
  )
  local opts = ar.telescope.opts
  vim.g.telescope_add_extension({ 'heading' }, opts, {
    heading = { treesitter = true },
  })
  local mappings = {
    { '<leader>fU', '<Cmd>Telescope heading<CR>', desc = 'headings' },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
  end
end

if ar.config.picker.variant == 'telescope' then
  map(
    'n',
    '<leader>fl',
    function()
      require('telescope.builtin').find_files({
        cwd = vim.fn.stdpath('data') .. '/site/pack',
        hidden = true,
      })
    end,
    { desc = 'surf plugins' }
  )
end
