local api = vim.api
local git_cond = require('ar.utils.git').git_cond

return {
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
        ['Conflict Choose Base (Diffview)'] = diffview_conflict_choose('base'),
        ['Conflict Choose Ours (Diffview)'] = diffview_conflict_choose('ours'),
        ['Conflict Choose Theirs (Diffview)'] = diffview_conflict_choose(
          'theirs'
        ),
        ['Conflict Choose None (Diffview)'] = diffview_conflict_choose('none'),
        ['Conflict Choose Both (Diffview)'] = diffview_conflict_choose('all'),
        ['Conflict Show Base (Diffview)'] = diffview_conflict('base'),
        ['Conflict Show Ours (Diffview)'] = diffview_conflict('ours'),
        ['Conflict Show Theirs (Diffview)'] = diffview_conflict('theirs'),
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
}
