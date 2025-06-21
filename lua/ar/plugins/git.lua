local api = vim.api
local fmt = string.format
local cwd = fmt('%s', vim.fn.getcwd())
local icons = ar.ui.icons
local border = ar.ui.current.border
local left_block = icons.separators.left_block

local minimal = ar.plugins.minimal
local is_git = ar.is_git_repo() or ar.is_git_env()

local git_cond = function(plugin)
  local condition = ar.git.enable and is_git
  return ar.get_plugin_cond(plugin, condition)
end

return {
  -- FIX: Causes performance issues in large folds (~1000+ lines)
  {
    'TungstnBallon/conflict.nvim',
    cond = function() return git_cond('conflict.nvim') and false end,
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { '<leader>g?n', '<Plug>ConflictJumpToNext', desc = 'next conflict' },
      { '<leader>g?p', '<Plug>ConflictJumpToPrevious', desc = 'prev conflict' },
      {
        '<leader>g??',
        '<Plug>ConflictResolveAroundCursor',
        desc = 'resolve conflict',
      },
    },
  },
  {
    'yyk/find-git-root.nvim',
    cond = function() return git_cond('find-git-root.nvim') end,
    cmd = { 'CdGitRoot' },
  },
  {
    'kilavila/nvim-gitignore',
    cond = function() return ar.get_plugin_cond('nvim-gitignore', not minimal) end,
    cmd = { 'Gitignore', 'Licenses' },
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Generate Gitignore'] = 'Gitignore',
        ['Generate License'] = 'Licenses',
      })
    end,
  },
  {
    'yutkat/git-rebase-auto-diff.nvim',
    cond = function() return git_cond('git-rebase-auto-diff.nvim') end,
    ft = { 'gitrebase' },
    opts = {},
  },
  {
    'tpope/vim-fugitive',
    cond = function() return git_cond('vim-fugitive') end,
    keys = { { '<localleader>gS', '<Cmd>G<CR>', desc = 'fugitive' } },
  },
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
    'sindrets/diffview.nvim',
    cond = function() return git_cond('diffview.nvim') end,
    cmd = {
      'DiffviewOpen',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
    },
    -- stylua: ignore
    keys = {
      { '<localleader>gd', '<Cmd>DiffviewOpen<CR>', desc = 'diffview: open' },
      {  mode = 'v', '<localleader>gh', [[:'<'>DiffviewFileHistory<CR>]], desc = 'diffview: file history' },
      { '<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', desc = 'diffview: file history', },
      { '<localleader>gx', '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>', desc = 'diffview: close all buffers', },
    },
    init = function()
      local function show_commit(commit_sha)
        vim.cmd(
          'DiffviewOpen '
            .. commit_sha
            .. '^..'
            .. commit_sha
            .. '  --selected-file='
            .. vim.fn.expand('%:p')
        )
      end

      local function show_commit_at_line()
        if not ar.plugin_available('agitator.nvim') then return end

        local commit_sha = require('agitator').git_blame_commit_for_line()
        if commit_sha == nil then return end
        show_commit(commit_sha)
      end

      local function diffview_conflict(which)
        return function()
          local view = require('diffview.lib').get_current_view()
          if view == nil then
            vim.notify('No diffview found', vim.log.levels.ERROR)
            return
          end
          ---@diagnostic disable-next-line: undefined-field
          local merge_ctx = view.merge_ctx
          if merge_ctx then show_commit(merge_ctx[which].hash) end
        end
      end

      local function diffview_conflict_choose(which)
        return function()
          local actions = require('diffview.actions')
          actions.conflict_choose_all(which)()
        end
      end

      local function project_history()
        local project_root = vim.fs.root(0, '.git')
        if ar.falsy(project_root) then return end
        vim.cmd('DiffviewFileHistory ' .. project_root)
      end

      local function display_commit_from_hash()
        vim.ui.input(
          { prompt = 'Enter git commit id:', kind = 'center_win' },
          function(input)
            if input ~= nil then
              vim.cmd(':DiffviewOpen ' .. input .. '^..' .. input)
            end
          end
        )
      end

      local function cherry_pick_from_hash()
        vim.ui.input(
          { prompt = 'Enter git commit id:', kind = 'center_win' },
          function(input)
            if input ~= nil then vim.cmd(':term! git cherry-pick ' .. input) end
          end
        )
      end

      ar.add_to_select_menu('git', {
        ['Conflict Choose Base'] = diffview_conflict_choose('base'),
        ['Conflict Choose Ours'] = diffview_conflict_choose('ours'),
        ['Conflict Choose Theirs'] = diffview_conflict_choose('theirs'),
        ['Conflict Choose None'] = diffview_conflict_choose('none'),
        ['Conflict Choose Both'] = diffview_conflict_choose('all'),
        ['Conflict Show Base'] = diffview_conflict('base'),
        ['Conflict Show Ours'] = diffview_conflict('ours'),
        ['Conflict Show Theirs'] = diffview_conflict('theirs'),
        ['Show Commit At Line'] = show_commit_at_line,
        ['Browse Project History'] = project_history,
        ['Show Commit From Hash'] = display_commit_from_hash,
        ['Cherry Pick From Hash'] = cherry_pick_from_hash,
        ['Open Diffview'] = 'DiffviewOpen',
        ['Browse File Commit History'] = 'DiffviewFileHistory %',
      })
    end,
    opts = {
      default_args = { DiffviewFileHistory = { '%' } },
      enhanced_diff_hl = true,
      hooks = {
        diff_buf_read = function()
          local opt = vim.opt_local
          opt.wrap, opt.list, opt.relativenumber = false, false, false
          opt.colorcolumn = ''
        end,
      },
      keymaps = {
        view = {
          q = '<Cmd>DiffviewClose<CR>',
          [']x'] = function()
            require('diffview.config').actions.prev_conflict()
            vim.cmd('norm! zz') -- center on screen
          end,
          ['[x'] = function()
            require('diffview.config').actions.next_conflict()
            vim.cmd('norm! zz') -- center on screen
          end,
        },
        file_panel = {
          q = '<Cmd>DiffviewClose<CR>',
          {
            'n',
            ']x',
            function() require('diffview.config').actions.prev_conflict() end,
            { desc = 'go to previous conflict' },
          },
          {
            'n',
            '[x',
            function() require('diffview.config').actions.next_conflict() end,
            { desc = 'go to next conflict' },
          },
          {
            'n',
            '[[',
            function() -- jump to first file in the diff
              local view = require('diffview.lib').get_current_view()
              if view then
                ---@diagnostic disable-next-line: undefined-field
                view:set_file(view.panel:ordered_file_list()[1], false, true)
              end
            end,
            { desc = 'jump to first file' },
          },
          {
            'n',
            'c',
            function()
              -- cc should commit from diffview same as from neogit
              vim.cmd('DiffviewClose')
              api.nvim_set_current_tabpage(1) -- in case i had a dadbod in the second tab, where i could have jumped after closing the diffview tab
              -- check whether we already have a neogit tab
              local tps = api.nvim_list_tabpages()
              for _, tp in ipairs(tps) do
                local wins = api.nvim_tabpage_list_wins(tp)
                if #wins == 1 then
                  local buf = api.nvim_win_get_buf(wins[1])
                  local ft = api.nvim_get_option_value('ft', { buf = buf })
                  if ft == 'NeogitStatus' then
                    -- switch to that tabpage
                    api.nvim_set_current_tabpage(tp)
                    require('neogit').open({ 'commit' })
                    return
                  end
                end
              end
              -- neogit is not open, open it
              vim.cmd('Neogit')
              require('neogit').open({ 'commit' })
            end,
            { desc = 'invoke diffview' },
          },
          {
            'n',
            '<leader>x',
            function()
              if vim.w.orig_width == nil then
                local bufnr = api.nvim_win_get_buf(0)
                local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local maxcols = 0
                for _, line in ipairs(lines) do
                  local cols = #line
                  if cols > maxcols then maxcols = cols end
                end
                vim.w.orig_width = api.nvim_win_get_width(0)
                api.nvim_win_set_width(0, maxcols)
              else
                api.nvim_win_set_width(0, vim.w.orig_width)
                vim.w.orig_width = nil
              end
            end,
            { desc = 'toggle expansion of file panel to fit' },
          },
          {
            'n',
            'X',
            function()
              local rel_path = require('diffview.lib')
                .get_current_view().panel
                :get_item_at_cursor().path
              local git_root = vim.fs.root(vim.fn.getcwd(), '.git')
              local absolute_file_path = git_root .. '/' .. rel_path
              local stat = vim.uv.fs_stat(absolute_file_path)
              if stat and stat.type == 'directory' then
                vim.ui.select({ 'Yes', 'No' }, {
                  prompt = 'Discard changes in the whole git folder '
                    .. rel_path
                    .. '?',
                }, function(choice)
                  if choice == 'Yes' then
                    vim.system(
                      { 'git', 'checkout', '--', rel_path .. '/' },
                      { text = true, cwd = git_root },
                      vim.schedule_wrap(function(res)
                        if #res.stderr + #res.stdout > 0 then
                          vim.notify(res.stderr .. ' ' .. res.stdout)
                        end
                      end)
                    )
                  end
                end)
              else
                require('diffview.config').actions.restore_entry()
              end
            end,
            { desc = 'restore entry to the state on the left side' },
          },
        },
        file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
      },
    },
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
        add = { highlight = 'GitSignsAdd', text = left_block },
        change = { highlight = 'GitSignsChange', text = left_block },
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
  },
  {
    'almo7aya/openingh.nvim',
    cond = function() return git_cond('openingh.nvim') end,
    cmd = { 'OpenInGHFile', 'OpenInGHRepo', 'OpenInGHFileLines' },
    init = function()
      ar.add_to_select_menu('git', {
        ['Open File In GitHub'] = 'OpenInGHFile',
        ['Open Line In GitHub'] = 'OpenInGHFileLines',
        ['Open Repo In GitHub'] = 'OpenInGHRepo',
      })
    end,
    keys = {
      {
        '<leader>gof',
        function()
          vim.cmd('OpenInGHFile')
          vim.notify('opening file in github', 'info', { title = 'openingh' })
        end,
        desc = 'openingh: open file',
      },
      {
        '<leader>gor',
        function()
          vim.cmd('OpenInGHRepo')
          vim.notify('opening repo in github', 'info', { title = 'openingh' })
        end,
        desc = 'openingh: open repo',
      },
      {
        '<leader>gol',
        function()
          vim.cmd('OpenInGHFileLines')
          vim.notify(
            'opening file line in github',
            'info',
            { title = 'openingh' }
          )
        end,
        desc = 'openingh: open to line',
        mode = { 'n', 'x' },
      },
    },
  },
  {
    'https://git.sr.ht/~tomleb/repo-url.nvim',
    cond = function() return ar.get_plugin_cond('repo-url.nvim', not minimal) end,
    -- stylua: ignore
    keys= {
      {  mode = { 'n', 'v' }, '<localleader>gyb', ':lua require("repo-url").copy_blob_url()<CR>', desc= 'copy blob URL' },
      {  mode = { 'n', 'v' }, '<localleader>gob', ':lua require("repo-url").open_blob_url()<CR>', desc= 'open blob URL' },
      {  mode = { 'n', 'v' }, '<leader>gyu', ':lua require("repo-url").copy_blame_url()<CR>', desc= 'copy blame URL' },
      {  mode = { 'n', 'v' }, '<localleader>gou', ':lua require("repo-url").open_blame_url()<CR>', desc= 'open blame URL' },
      {  mode= { 'n', 'v' }, '<localleader>gyh', ':lua require("repo-url").copy_history_url()<CR>', desc= 'copy history URL' },
      {  mode= { 'n', 'v' }, '<localleader>goh', ':lua require("repo-url").open_history_url()<CR>', desc= 'open history URL' },
      {  mode= { 'n', 'v' }, '<localleader>gyr', ':lua require("repo-url").copy_raw_url()<CR>', desc= 'copy raw URL' },
      {  mode= { 'n', 'v' }, '<localleader>gor', ':lua require("repo-url").open_raw_url()<CR>', desc= 'open raw URL' },
    },
    opts = {},
    config = function(_, opts)
      require('repo-url').setup(opts)

      local ru = require('repo-url')

      -- For Go's go.mod file, generate permalinks to the dependency under the
      -- cursor and copy to the clipboard or open in the default browser.
      ar.augroup('repo-url', {
        event = { 'FileType' },
        pattern = 'gomod',
        command = function(args)
          map(
            'n',
            '<localleader>gyg',
            function() ru.copy_gomod_tree_url() end,
            { desc = 'copy gomod URL', buffer = args.buf }
          )
          map(
            'n',
            '<localleader>gog',
            function() ru.open_gomod_tree_url() end,
            { desc = 'open gomod URL', buffer = args.buf }
          )
        end,
      }, {
        -- For Go's go.sum file, generate permalinks to the dependency under the
        -- cursor and copy to the clipboard or open in the default browser.
        event = { 'FileType' },
        pattern = 'gosum',
        command = function(args)
          map(
            'n',
            '<localleader>gyg',
            function() ru.copy_gosum_tree_url() end,
            { desc = 'copy gosum URL', buffer = args.buf }
          )
          map(
            'n',
            '<localleader>gog',
            function() ru.open_gosum_tree_url() end,
            { desc = 'open gosum URL', buffer = args.buf }
          )
        end,
      })
    end,
  },
  {
    'linrongbin16/gitlinker.nvim',
    cond = function() return git_cond('gitlinker.nvim') end,
    cmd = { 'GitLink' },
    opts = {

      router = {
        default_branch = {
          ['^github%.com'] = 'https://github.com/'
            .. '{_A.USER}/'
            .. '{_A.REPO}/blob/'
            .. '{_A.DEFAULT_BRANCH}/' -- always 'master'/'main' branch
            .. '{_A.FILE}?plain=1' -- '?plain=1'
            .. '#L{_A.LSTART}'
            .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
        },
        current_branch = {
          ['^github%.com'] = 'https://github.com/'
            .. '{_A.USER}/'
            .. '{_A.REPO}/blob/'
            .. '{_A.CURRENT_BRANCH}/' -- always current branch
            .. '{_A.FILE}?plain=1' -- '?plain=1'
            .. '#L{_A.LSTART}'
            .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
        },
        blame_default_branch = {
          ['^github%.com'] = 'https://github.com/'
            .. '{_A.USER}/'
            .. '{_A.REPO}/blame/'
            .. '{_A.DEFAULT_BRANCH}/'
            .. '{_A.FILE}?plain=1' -- '?plain=1'
            .. '#L{_A.LSTART}'
            .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
        },
      },
    },
    keys = {
      {
        '<leader>gom',
        '<cmd>GitLink default_branch<cr>',
        desc = 'gitlinker: copy line URL (main branch)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gob',
        '<cmd>GitLink current_branch<cr>',
        desc = 'gitlinker: copy line URL (current branch)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>goc',
        '<cmd>GitLink<cr>',
        desc = 'gitlinker: copy line URL (commit)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gbm',
        '<cmd>GitLink! blame_default_branch<cr>',
        desc = 'gitlinker: github blame (main branch)',
        mode = { 'v', 'n' },
      },
    },
  },
  {
    'emmanueltouzery/agitator.nvim',
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

      ar.add_to_select_menu('git', {
        ['Time Machine'] = time_machine,
        ['Search In Another Branch'] = search_in_another_branch,
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
  {
    'FabijanZulj/blame.nvim',
    cond = function() return git_cond('blame.nvim') end,
    cmd = { 'BlameToggle' },
    init = function()
      ar.add_to_select_menu('git', { ['Toggle Blame'] = 'BlameToggle' })
    end,
    config = function() require('blame').setup() end,
  },
  {
    'dlvhdr/gh-addressed.nvim',
    cond = function() return git_cond('gh-addressed.nvim') end,
    cmd = 'GhReviewComments',
    -- stylua: ignore
    keys = {
      { '<leader>gc', '<Cmd>GhReviewComments<CR>', desc = 'github review comments' },
    },
  },
  {
    'aaronhallaert/advanced-git-search.nvim',
    cond = function() return git_cond('advanced-git-search.nvim') end,
    cmd = { 'AdvancedGitSearch' },
    init = function()
      ar.add_to_select_menu('git', { ['Git Search'] = 'AdvancedGitSearch' })
    end,
    config = function()
      require('telescope').load_extension('advanced_git_search')
    end,
  },
  {
    '2kabhishek/co-author.nvim',
    cond = function() return git_cond('co-author.nvim') end,
    cmd = 'CoAuthor',
    init = function()
      ar.add_to_select_menu('git', { ['List Authors'] = 'CoAuthor' })
    end,
  },
  {
    'niuiic/git-log.nvim',
    cond = function() return git_cond('git-log.nvim') end,
    -- stylua: ignore
    keys = {
      { '<leader>gL', "<Cmd>lua require'git-log'.check_log()<CR>", mode = { 'n', 'x' }, desc = 'git-log: show line/selection log', },
    },
    dependencies = { 'niuiic/core.nvim' },
  },
  {
    'rbong/vim-flog',
    cond = function() return git_cond('vim-flog') end,
    init = function()
      ar.add_to_select_menu('git', { ['View Branch Graph'] = 'Flog' })
    end,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
  },
  {
    'ldelossa/gh.nvim',
    cond = function() return git_cond('gh.nvim') end,
    -- stylua: ignore
    cmd = {
      'GHCloseCommit', 'GHExpandCommit', 'GHOpenToCommit', 'GHPopOutCommit',
      'GHCollapseCommit', 'GHPreviewIssue', 'LTPanel', 'GHStartReview',
      'GHCloseReview', 'GHDeleteReview', 'GHExpandReview', 'GHSubmitReview',
      'GHCollapseReview', 'GHClosePR', 'GHPRDetails', 'GHExpandPR', 'GHOpenPR',
      'GHPopOutPR', 'GHRefreshPR', 'GHOpenToPR', 'GHCollapsePR', 'GHCreateThread',
      'GHNextThread', 'GHToggleThread',
    },
    dependencies = {
      {
        'ldelossa/litee.nvim',
        config = function() require('litee.lib').setup() end,
      },
    },
    config = function() require('litee.gh').setup() end,
  },
  {
    'isakbm/gitgraph.nvim',
    cond = function() return git_cond('gitgraph.nvim') end,
    opts = {
      symbols = {
        merge_commit = 'M',
        commit = '*',
      },
      format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },
    },
    init = function()
      map(
        'n',
        '<leader>gG',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        { desc = 'git graph: draw' }
      )
    end,
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'ejrichards/baredot.nvim',
    cond = git_cond('baredot.nvim') and false,
    lazy = false,
    opts = {
      git_dir = '~/.dots/dotfiles', -- Change this path
    },
  },
  {
    'akinsho/git-conflict.nvim',
    cond = git_cond('git-conflict.nvim') and false,
    event = 'BufReadPre',
    opts = {
      disable_diagnostics = true,
      default_mappings = {
        ours = 'c<',
        theirs = 'c>',
        none = 'co',
        both = 'c.',
        next = ']x',
        prev = '[x',
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('git-conflict', {
        {
          theme = {
            ['onedark'] = {
              { GitConflictCurrent = { inherit = 'DiffAdd' } },
              { GitConflictCurrentLabel = { inherit = 'DiffAdd' } },
              { GitConflictIncoming = { inherit = 'DiffDelete' } },
              { GitConflictIncomingLabel = { inherit = 'DiffDelete' } },
              { GitConflictAncestor = { inherit = 'DiffText' } },
              { GitConflictAncestorLabel = { inherit = 'DiffText' } },
            },
          },
        },
      })
      require('git-conflict').setup(opts)
    end,
  },
  {
    'SuperBo/fugit2.nvim',
    enabled = false,
    cond = git_cond('fugit2.nvim') and false,
    cmd = { 'Fugit2', 'Fugit2Diff', 'Fugit2Graph' },
    keys = {
      { '<leader><localleader>F', '<Cmd>Fugit2<CR>', desc = 'fugit2: open' },
    },
    opts = { width = 100 },
  },
  {
    'dlvhdr/gh-blame.nvim',
    enabled = false,
    cond = git_cond('gh-blame.nvim') and false,
    -- stylua: ignore
    keys = {
      { '<leader>gbp', '<Cmd>GhBlameCurrentLine<CR>', desc = 'blame current line (PR)' },
    },
  },
  {
    '2kabhishek/octohub.nvim',
    enabled = false,
    cond = function() return git_cond('octohub.nvim') end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>o', group = 'Octohub' })
    end,
    cmd = {
      'OctoRepos',
      'OctoRepo',
      'OctoStats',
      'OctoActivityStats',
      'OctoContributionStats',
      'OctoRepoStats',
      'OctoProfile',
      'OctoRepoWeb',
    },
    -- stylua: ignore
    keys = {
      { '<leader><leader>oo', '<Cmd>OctoRepos<CR>', desc = 'octohub: all repos' },
      { '<leader><leader>os', '<Cmd>OctoRepos sort:stars<CR>', desc = 'octohub: top starred repos' },
      { '<leader><leader>oi', '<Cmd>OctoRepos sort:issues<CR>', desc = 'octohub: repos with issues' },
      { '<leader><leader>ou', '<Cmd>OctoRepos sort:updated<CR>', desc = 'octohub: recently updated repos' },
      { '<leader><leader>op', '<Cmd>OctoRepos type:private<CR>', desc = 'octohub: private repos' },
      { '<leader><leader>of', '<Cmd>OctoRepos type:fork<CR>', desc = 'octohub: forked repos' },
      { '<leader><leader>oc', '<Cmd>OctoRepo<CR>', desc = 'octohub: open repo' },
      { '<leader><leader>ot', '<Cmd>OctoStats<CR>', desc = 'octohub: all stats' },
      { '<leader><leader>oa', '<Cmd>OctoActivityStats<CR>', desc = 'octohub: activity stats' },
      { '<leader><leader>og', '<Cmd>OctoContributionStats<CR>', desc = 'octohub: contribution graph' },
      { '<leader><leader>or', '<Cmd>OctoRepoStats<CR>', desc = 'octohub: repo stats' },
    },
    dependencies = { '2kabhishek/utils.nvim', 'nvim-telescope/telescope.nvim' },
    opts = { add_default_keybindings = false },
  },
}
