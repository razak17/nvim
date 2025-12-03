local fmt = string.format
local cwd = fmt('%s', vim.fn.getcwd())
local icons = ar.ui.icons
local border = ar.ui.current.border.default
local left_block = icons.separators.left_block

local statuscolumn_enabled = ar.config.ui.statuscolumn.enable
local git_cond = require('ar.utils.git').git_cond

return {
  {
    'NeogitOrg/neogit',
    cond = function() return git_cond('neogit') end,
    cmd = 'Neogit',
    -- stylua: ignore
    keys = {
      {
        '<localleader>gs',
        function() require('neogit').open({
          cwd = vim.uv.cwd(),
          no_expand = true
        }) end,
        desc = 'open status buffer',
      },
      { '<localleader>gc', function() require('neogit').open({ 'commit' }) end, desc = 'open commit buffer', },
      { '<localleader>gl', function() require('neogit.popups.pull').create() end, desc = 'open pull popup', },
      { '<localleader>gp', function() require('neogit.popups.push').create({}) end, desc = 'open push popup', },
    },
    opts = {
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
    },
    config = function(_, opts)
      ar.highlight.plugin('neogit', {
        theme = {
          ['habamax'] = {
            {
              NeogitDiffAdd = {
                bg = { from = 'DiffAdd', attr = 'fg', alter = -0.65 },
                fg = { from = 'Normal' },
              },
            },
            {
              NeogitDiffDelete = {
                fg = { from = 'Normal' },
                bg = { from = 'DiffDelete', attr = 'fg', alter = -0.7 },
              },
            },
            { NeogitHunkHeader = { inherit = 'FloatTitle' } },
            { NeogitChangeAdded = { fg = { from = 'DiffAdd' } } },
            { NeogitChangeModified = { fg = { from = 'DiffChange' } } },
            { NeogitChangeDeleted = { fg = { from = 'DiffDelete' } } },
            { NeogitChangeCopied = { fg = { from = 'Change' } } },
            {
              NeogitChangeRenamed = {
                fg = { from = 'DiffChange', alter = 0.35 },
              },
            },
            {
              NeogitChangeNewFile = { fg = { from = 'DiffAdd', alter = 0.35 } },
            },
            { NeogitDiffAddHighlight = { fg = { from = 'Normal' } } },
          },
          ['retrobox'] = {
            {
              NeogitDiffAdd = {
                bg = { from = 'DiffChange', attr = 'fg', alter = -0.3 },
                fg = { from = 'Normal' },
                reverse = false,
              },
            },
            { NeogitDiffAddHighlight = { fg = { from = 'Normal' } } },
          },
          ['slate'] = {
            {
              NeogitDiffAdd = {
                bg = { from = 'DiffAdd', alter = -0.4 },
                fg = { from = 'Normal' },
              },
            },
            {
              NeogitDiffDelete = {
                bg = { from = 'DiffDelete', alter = -0.5 },
                fg = { from = 'Normal' },
              },
            },
            { NeogitDiffAddHighlight = { fg = { from = 'Normal' } } },
          },
          ['wildcharm'] = {
            {
              NeogitDiffAdd = {
                bg = { from = 'DiffAdd', attr = 'bg' },
              },
            },
            {
              NeogitDiffDelete = {
                bg = { from = 'Error', attr = 'fg', alter = -0.3 },
              },
            },
            { NeogitDiffAddHighlight = { fg = { from = 'Normal' } } },
          },
          ['onedark'] = {
            { NeogitHunkHeader = { inherit = 'Headline2', bold = true } },
            { NeogitDiffHeader = { inherit = 'Headline2', bold = true } },
            { NeogitWinSeparator = { link = 'WinSeparator' } },
            { NeogitCommitViewHeader = { link = 'Normal' } },
            {
              NeogitCursorLine = {
                bg = { from = 'CursorLine' },
                fg = { from = 'Normal' },
              },
            },
          },
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

      require('neogit').setup(opts)
    end,
  },
  {
    'chrisgrieser/nvim-tinygit',
    cond = function() return git_cond('nvim-tinygit') end,
    -- stylua: ignore
    keys = {
      { '<leader><leader>ga', '<Cmd>lua require("tinygit").amendOnlyMsg()<CR>', desc = 'tinygit: amend commit' },
      { '<leader><leader>gA', '<Cmd>lua require("tinygit").amendNoEdit()<CR>', desc = 'tinygit: amend using last commit message' },
      { '<leader><leader>gc', '<Cmd>lua require("tinygit").smartCommit()<CR>', desc = 'tinygit: smart commit' },
      { '<leader><leader>gp', '<Cmd>lua require("tinygit").push()<CR>', desc = 'tinygit: push' },
      { '<leader><leader>gg', '<Cmd>lua require("tinygit").createGitHubPr()<CR>', desc = 'tinygit: create pr' },
      { '<leader><leader>gu', '<Cmd>lua require("tinygit").undoLastCommitOrAmend()<CR>', desc = 'tinygit: undo last commit' },
      { '<leader><leader>gii', '<Cmd>lua require("tinygit").issuesAndPrs()<CR>', desc = 'tinygit: issues and prs' },
      { '<leader><leader>gio', '<Cmd>lua require("tinygit").openIssueUnderCursor()<CR>', desc = 'tinygit: open issue under cursor' },
      { '<leader><leader>gs', '<Cmd>lua require("tinygit").interactiveStaging()<CR>', desc = 'tinygit: add' },
      { '<leader><leader>gSP', '<Cmd>lua require("tinygit").stashPush()<CR>', desc = 'tinygit: stash push' },
      { '<leader><leader>gSp', '<Cmd>lua require("tinygit").stashPop()<CR>', desc = 'tinygit: stash pop' },
      { '<leader><leader>gof', '<Cmd>lua require("tinygit").githubUrl("file")<CR>', desc = 'tinygit: open file' },
      { '<leader><leader>gor', '<Cmd>lua require("tinygit").githubUrl("repo")<CR>', desc = 'tinygit: open repo' },
      { mode = { 'n', 'x' }, '<leader><leader>gh', '<Cmd>lua require("tinygit").fileHistory()<CR>', desc = 'tinygit: file history' },
    },
    -- ft = { 'gitrebase', 'gitcommit' },
  },
  {
    'lewis6991/gitsigns.nvim',
    cond = function() return git_cond('gitsigns.nvim') end,
    event = { 'BufRead', 'BufNewFile' },
    init = function()
      ar.add_to_select_menu('git', {
        ['Toggle Current Line Blame'] = 'Gitsigns toggle_current_line_blame',
        ['Reset Buffer'] = 'Gitsigns reset_buffer',
      })
    end,
    opts = {
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
      current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
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
          return ar.demicolon_jump(function(opts)
            local direction = opts.forward and 'next' or 'prev'
            gs.nav_hunk(direction)
          end, options)
        end

        map('n', ']h', jump({ forward = true }), { desc = 'next hunk' })
        map('n', '[h', jump({ forward = false }), { desc = 'previous hunk' })
      end,
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      ar.highlight.plugin('gitsigns', {
        theme = {
          ['default'] = {
            {
              GitSignsAdd = {
                fg = { from = 'DiffAdd', attr = 'bg', alter = 1.4 },
              },
            },
          },
          ['habamax'] = {
            {
              GitSignsChange = {
                fg = { from = 'DiffChange', attr = 'fg', alter = -0.1 },
                reverse = false,
              },
            },
          },
        },
      })
    end,
  },
  {
    'razak17/agitator.nvim',
    cond = function() return git_cond('agitator.nvim') end,
    init = function()
      local function time_machine()
        require('agitator').git_time_machine({ use_current_win = true })
      end

      local function open_file_from_branch()
        require('agitator').open_file_git_branch()
      end

      local function search_in_another_branch()
        require('agitator').search_git_branch()
      end

      local function search_in_added()
        require('agitator.search_in_added').search_in_added()
      end

      ar.add_to_select_menu('git', {
        ['Time Machine'] = time_machine,
        ['Search Word In Another Branch'] = search_in_another_branch,
        ['Search In Added Files'] = search_in_added,
        ['Open File From Branch'] = open_file_from_branch,
      })
    end,
    keys = {
      {
        '<leader>gbo',
        "<Cmd>lua require'agitator'.git_blame_toggle()<CR>",
        desc = 'agitator: toggle blame',
      },
    },
  },
}
