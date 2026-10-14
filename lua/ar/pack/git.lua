local fmt = string.format
local cwd = fmt('%s', vim.fn.getcwd())
local icons = ar.ui.icons
local border = ar.ui.current.border.default
local left_block = icons.separators.left_block

local statuscolumn_enabled = ar.config.ui.statuscolumn.enable
local git_cond = require('ar.utils.git').git_cond

ar.pack.add({
  {
    src = 'https://github.com/NeogitOrg/neogit',
    cmd = { 'Neogit' },
    cond = git_cond('neogit'),
    keys = function(load)
      map('n', '<localleader>gs', function()
        load()
        require('neogit').open({ cwd = vim.uv.cwd(), no_expand = true })
      end, { desc = 'open status buffer' })
      map('n', '<localleader>gc', function()
        load()
        require('neogit').open({ 'commit' })
      end, { desc = 'open commit buffer' })
      map('n', '<localleader>gl', function()
        load()
        require('neogit.popups.pull').create()
      end, { desc = 'open pull popup' })
      map('n', '<localleader>gp', function()
        load()
        require('neogit.popups.push').create({})
      end, { desc = 'open push popup' })
    end,
    setup = function()
      local base_hl = {
        { NeogitNormal = { link = 'Normal' } },
        { NeogitNormalFloat = { link = 'NormalFloat' } },
        { NeogitFloatBorder = { link = 'FloatBorder' } },
        { NeogitWinSeparator = { link = 'WinSeparator' } },
        { NeogitCursorLineNr = { link = 'CursorLineNr' } },
        { NeogitDiffAdd = { bg = { from = 'DiffAdd' } } },
        { NeogitDiffDelete = { bg = { from = 'DiffDelete' } } },
        { NeogitHunkHeader = { inherit = 'FloatTitle' } },
        { NeogitChangeAdded = { fg = { from = 'DiffAdd' } } },
        { NeogitChangeModified = { fg = { from = 'DiffChange' } } },
        { NeogitChangeDeleted = { fg = { from = 'DiffDelete' } } },
        { NeogitChangeRenamed = { fg = { from = 'Change' } } },
        { NeogitChangeNewFile = { fg = { from = 'DiffAdd' } } },
        { NeogitDiffAddHighlight = { fg = { from = 'Normal' } } },
      }
      local github_dark_hl = {
        {
          NeogitDiffAdd = {
            bg = { from = 'NeogitDiffAdd', attr = 'fg', alter = -0.6 },
          },
        },
        {
          NeogitDiffDelete = {
            bg = { from = 'DiffDelete', attr = 'fg', alter = -0.75 },
          },
        },
        { NeogitHunkHeader = { inherit = 'FloatTitle' } },
      }

      ar.highlight.plugin('neogit', {
        theme = {
          ['default'] = base_hl,
          ['habamax'] = base_hl,
          ['retrobox'] = base_hl,
          ['slate'] = base_hl,
          ['vim'] = base_hl,
          ['wildcharm'] = base_hl,
          ['onedark'] = {
            { NeogitHunkHeader = { inherit = 'FloatTitle' } },
            { NeogitDiffHeader = { inherit = 'FloatTitle' } },
            { NeogitCommitViewHeader = { link = 'FloatTitle' } },
          },
          ['github_dark_dimmed'] = github_dark_hl,
          ['github_dark_tritanopia'] = github_dark_hl,
        },
      })

      ar.augroup('NeogitCloseDiff', {
        event = { 'BufEnter' },
        command = function(args)
          if vim.bo[args.buf].filetype == 'DiffviewFiles' then
            map(
              'n',
              'Q',
              function()
                vim.cmd(
                  'lua require("neogit.integrations.diffview").diffview_mappings["close"]()'
                )
              end,
              { buffer = args.buf }
            )
          end
        end,
      })

      require('neogit').setup({
        disable_signs = false,
        disable_hint = true,
        disable_commit_confirmation = true,
        disable_builtin_notifications = true,
        disable_insert_on_commit = false,
        disable_context_highlighting = true,
        signs = {
          section = { icons.misc.chevron_right, icons.misc.chevron_down }, -- "", "󰘕"
          item = { '▸', '▾' },
          hunk = { '樂', '' },
        },
        integrations = { diffview = true },
        graph_style = 'kitty',
        treesitter_diff_highlight = true,
      })
    end,
  },
  {
    src = 'https://github.com/chrisgrieser/nvim-tinygit',
    cond = git_cond('nvim-tinygit'),
    keys = function(load)
      map('n', '<leader><leader>ga', function()
        load()
        require('tinygit').amendOnlyMsg()
      end, { desc = 'tinygit: amend commit' })
      map('n', '<leader><leader>gA', function()
        load()
        require('tinygit').amendNoEdit()
      end, { desc = 'tinygit: amend using last commit message' })
      map('n', '<leader><leader>gc', function()
        load()
        require('tinygit').smartCommit()
      end, { desc = 'tinygit: smart commit' })
      map('n', '<leader><leader>gp', function()
        load()
        require('tinygit').push()
      end, { desc = 'tinygit: push' })
      map('n', '<leader><leader>gg', function()
        load()
        require('tinygit').createGitHubPr()
      end, { desc = 'tinygit: create pr' })
      map('n', '<leader><leader>gu', function()
        load()
        require('tinygit').undoLastCommitOrAmend()
      end, { desc = 'tinygit: undo last commit' })
      map('n', '<leader><leader>gii', function()
        load()
        require('tinygit').issuesAndPrs()
      end, { desc = 'tinygit: issues and prs' })
      map('n', '<leader><leader>gio', function()
        load()
        require('tinygit').openIssueUnderCursor()
      end, { desc = 'tinygit: open issue under cursor' })
      map('n', '<leader><leader>gs', function()
        load()
        require('tinygit').interactiveStaging()
      end, { desc = 'tinygit: add' })
      map('n', '<leader><leader>gSP', function()
        load()
        require('tinygit').stashPush()
      end, { desc = 'tinygit: stash push' })
      map('n', '<leader><leader>gSp', function()
        load()
        require('tinygit').stashPop()
      end, { desc = 'tinygit: stash pop' })
      map('n', '<leader><leader>gof', function()
        load()
        require('tinygit').githubUrl('file')
      end, { desc = 'tinygit: open file' })
      map('n', '<leader><leader>gor', function()
        load()
        require('tinygit').githubUrl('repo')
      end, { desc = 'tinygit: open repo' })
      map({ 'n', 'x' }, '<leader><leader>gh', function()
        load()
        require('tinygit').fileHistory()
      end, { desc = 'tinygit: file history' })
    end,
  },
  {
    src = 'https://github.com/lewis6991/gitsigns.nvim',
    init = function()
      ar.add_to_select('git', {
        ['Toggle Current Line Blame'] = 'Gitsigns toggle_current_line_blame',
        ['Reset Buffer'] = 'Gitsigns reset_buffer',
      })
    end,
    cond = git_cond('gitsigns.nvim'),
    event = { 'BufRead', 'BufNewFile' },
    setup = function()
      local base_hl = {
        {
          GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg', alter = 1.25 } },
        },
        { GitSignsChange = { fg = { from = 'DiffChange', alter = 0.2 } } },
        {
          GitSignsDeleteVirtLn = {
            bg = { from = 'DiffDelete' },
            fg = { from = 'DiffDelete' },
            reverse = false,
          },
        },
      }

      ar.highlight.plugin('gitsigns', {
        theme = {
          ['catppuccin'] = base_hl,
          ['default'] = base_hl,
          ['habamax'] = base_hl,
          ['retrobox'] = base_hl,
          ['slate'] = base_hl,
          ['vim'] = base_hl,
          ['wildcharm'] = base_hl,
          ['kanagawa'] = {
            { GitSignsAdd = { bg = 'NONE' } },
            { GitSignsStagedAdd = { bg = 'NONE' } },
            {
              GitSignsChange = {
                bg = 'NONE',
                fg = { from = 'Directory', alter = -0.2 },
              },
            },
            { GitSignsStagedChange = { bg = 'NONE' } },
            { GitSignsDelete = { bg = 'NONE' } },
            { GitSignsStagedDelete = { bg = 'NONE' } },
          },
          ['github_dark_dimmed'] = {
            { GitSignsChange = { fg = { from = 'Directory', alter = -0.2 } } },
          },
          ['github_dark_tritanopia'] = {
            { GitSignsAdd = { fg = { from = 'DiffAdd', alter = -0.35 } } },
            { GitSignsChange = { fg = { from = 'Directory', alter = -0.2 } } },
          },
        },
      })

      require('gitsigns').setup({
        signs = {
          add = {
            highlight = 'GitSignsAdd',
            text = statuscolumn_enabled and left_block or ' ' .. left_block,
          },
          change = {
            highlight = 'GitSignsChange',
            text = statuscolumn_enabled and left_block or ' ' .. left_block,
          },
          delete = {
            highlight = 'GitSignsDelete',
            text = icons.misc.separator,
          },
          topdelete = { highlight = 'GitSignsChangeDelete', text = left_block },
          changedelete = { highlight = 'GitSignsChange', text = left_block },
          untracked = { highlight = 'GitSignsAdd', text = left_block },
        },
        _threaded_diff = true,
        word_diff = false,
        numhl = false,
        current_line_blame = not cwd:match('personal')
          and not cwd:match('dots'),
        current_line_blame_formatter = ' <author>, <author_time> · <summary>',
        preview_config = { border = border },
      -- stylua: ignore
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function bmap(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          map(mode, l, r, opts)
        end

        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage' })
        -- map('n', '<leader>hw', gs.toggle_word_diff, { desc = 'toggle word diff' })
        map('n', '<leader>hd', gs.toggle_deleted, { desc = 'show deleted lines' })
        map('n', '<leader>hp', gs.preview_hunk_inline, { desc = 'preview hunk inline' })
        map('n', '<leader>hb', gs.toggle_current_line_blame, { desc = 'toggle line blame' })
        map('n', '<leader>hx', gs.refresh, { desc = 'refresh' })

        map('n', '<leader>gbl', gs.blame_line, { desc = 'blame line' })
        map('n', '<leader>gr', gs.reset_buffer, { desc = 'reset entire buffer' })
        map('n', '<leader>gw', gs.stage_buffer, { desc = 'stage entire buffer' })
        map('n', '<leader>gq', function() gs.setqflist('all') end, { desc = 'list modified in qflist' })
        map('n', '<leader>gl', function() gs.setloclist() end, { desc = 'list modified in localist' })
        bmap({ 'n', 'v' }, '<leader>hs', '<Cmd>Gitsigns stage_hunk<CR>', { desc = 'stage hunk' })
        bmap({ 'n', 'v' }, '<leader>hr', '<Cmd>Gitsigns reset_hunk<CR>', { desc = 'reset hunk' })
        bmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select hunk' })

        local function jump(options)
          return ar.jump(function(opts)
            local direction = opts.forward and 'next' or 'prev'
            gs.nav_hunk(direction)
          end, options)
        end

        map('n', ']h', jump({ forward = true }), { desc = 'next hunk' })
        map('n', '[h', jump({ forward = false }), { desc = 'previous hunk' })
      end,
      })
    end,
  },
  {
    src = 'https://github.com/razak17/agitator.nvim',
    cond = git_cond('agitator.nvim'),
    keys = function(load)
      local function time_machine()
        load()
        require('agitator').git_time_machine({ use_current_win = true })
      end

      local function open_file_from_branch()
        load()
        require('agitator').open_file_git_branch()
      end

      local function search_in_another_branch()
        load()
        require('agitator').search_git_branch()
      end

      local function search_in_added()
        load()
        require('agitator.search_in_added').search_in_added()
      end

      ar.add_to_select('git', {
        ['Time Machine'] = time_machine,
        ['Search Word In Another Branch'] = search_in_another_branch,
        ['Search In Added Files'] = search_in_added,
        ['Open File From Branch'] = open_file_from_branch,
      })

      map('n', '<leader>gbo', function()
        load()
        require('agitator').git_blame_toggle()
      end, { desc = 'agitator: toggle blame' })
    end,
  },
})
