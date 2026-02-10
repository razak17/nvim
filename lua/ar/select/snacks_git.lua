local L = vim.log.levels

local M = {}

local function diffview_open(range)
  if not ar.plugin_available('diffview.nvim') then return false end
  vim.cmd('DiffviewOpen ' .. range)
  return true
end

local function git_log_overrides()
  return {
    actions = {
      diffview_relative = function(picker, item)
        if not item then return end
        picker:close()
        diffview_open(item.commit .. '~1..' .. item.commit)
      end,
      diffview_all = function(picker, item)
        if not item then return end
        picker:close()
        diffview_open(item.commit)
      end,
      diffview_upstream = function(picker, item)
        if not item then return end
        picker:close()
        if not ar.plugin_available('diffview.nvim') then return end
        local res = vim
          .system({ 'git', 'rev-parse', 'upstream/master' }, { text = true })
          :wait()
        if res.code ~= 0 then
          vim.notify('git rev-parse upstream/master failed', L.ERROR)
          return
        end
        local rev = vim.trim(res.stdout or '')
        vim.cmd('DiffviewOpen ' .. rev .. ' ' .. item.commit)
      end,
      view_commit = function(picker, item)
        if not item then return end
        picker:close()
        diffview_open(item.commit .. '^..' .. item.commit)
      end,
      diff_two_commits = function(picker, item)
        local items = picker:selected({ fallback = true })
        if #items == 0 and item then items = { item } end
        picker:close()
        if not ar.plugin_available('diffview.nvim') then return end
        if #items == 1 then
          vim.cmd(
            'DiffviewOpen ' .. items[1].commit .. '^..' .. items[1].commit
          )
        elseif #items == 2 then
          vim.cmd(
            'DiffviewOpen ' .. items[1].commit .. '^..' .. items[2].commit
          )
        else
          vim.notify('Select two commits for diff', L.INFO)
        end
      end,
      rebase_interactive = function(_, item)
        if not item then return end
        vim.cmd('term! git rebase -i ' .. item.commit .. '~')
      end,
      cherry_pick = function(_, item)
        if not item then return end
        vim.cmd('term! git cherry-pick ' .. item.commit)
      end,
      revert_commit = function(_, item)
        if not item then return end
        vim.cmd('term! git revert ' .. item.commit)
      end,
      copy_commit = function(_, item)
        if not item then return end
        ar.copy_to_clipboard(
          item.commit,
          "Copied the commit GUID '" .. item.commit .. "' to the clipboard"
        )
      end,
    },
    win = {
      input = {
        keys = {
          ['<C-l>r'] = { 'diffview_relative', mode = { 'i', 'n' } },
          ['<C-l>a'] = { 'diffview_all', mode = { 'i', 'n' } },
          ['<C-l>u'] = { 'diffview_upstream', mode = { 'i', 'n' } },
          ['<C-v>'] = { 'view_commit', mode = { 'i', 'n' } },
          ['<C-f>'] = { 'diff_two_commits', mode = { 'i', 'n' } },
          ['<C-r>i'] = { 'rebase_interactive', mode = { 'i', 'n' } },
          ['<A-k>'] = { 'cherry_pick', mode = { 'i', 'n' } },
          ['<C-r>r'] = { 'revert_commit', mode = { 'i', 'n' } },
          ['<C-y>'] = { 'copy_commit', mode = { 'i', 'n' } },
        },
      },
    },
  }
end

function M.browse_commits()
  Snacks.picker.git_log(vim.tbl_deep_extend('force', git_log_overrides(), {}))
end

function M.browse_bcommits()
  Snacks.picker.git_log_file(
    vim.tbl_deep_extend('force', git_log_overrides(), {})
  )
end

local function branch_overrides()
  return {
    actions = {
      diff_branches = function(picker, item)
        local items = picker:selected({ fallback = true })
        if #items == 0 and item then items = { item } end
        picker:close()
        if not ar.plugin_available('diffview.nvim') then return end
        if #items == 1 then
          local branch = items[1].branch or items[1].commit
          if not branch then return end
          local diffspec
          if
            branch:match('develop')
            or branch:match('master')
            or branch:match('main')
          then
            diffspec = branch .. '...'
          else
            diffspec = '...' .. branch
          end
          vim.cmd('DiffviewOpen ' .. diffspec)
        elseif #items == 2 then
          local b1 = items[1].branch or items[1].commit
          local b2 = items[2].branch or items[2].commit
          if b1 and b2 then vim.cmd('DiffviewOpen ' .. b1 .. '...' .. b2) end
        end
      end,
      merge_branch = function(picker, item)
        if not item or not item.branch then return end
        picker:close()
        vim.cmd('term! git merge ' .. item.branch)
      end,
      delete_branch = function(picker, item)
        if not item or not item.branch then return end
        local branch = item.branch
        picker:close()
        if branch:match('^remotes/') then
          local remote = branch:gsub('^remotes/', '')
          local parts = vim.split(remote, '/', { plain = true })
          local origin = parts[1]
          table.remove(parts, 1)
          local name = table.concat(parts, '/')
          vim.system({ 'git', 'push', origin, '--delete', name })
        else
          vim.system({ 'git', 'branch', '-D', branch })
        end
      end,
      browse_branch_commits = function(picker, item)
        if not item or not item.branch then return end
        picker:close()
        Snacks.picker.git_log(
          vim.tbl_deep_extend('force', git_log_overrides(), {
            cmd_args = { item.branch },
          })
        )
      end,
      branch_history = function(picker, item)
        if not item or not item.branch then return end
        picker:close()
        if not ar.plugin_available('diffview.nvim') then return end
        local root = vim.fs.root(vim.fn.getcwd(), '.git')
        vim.cmd('DiffviewFileHistory ' .. root .. ' --range=' .. item.branch)
      end,
      copy_branch = function(_, item)
        if not item or not item.branch then return end
        ar.copy_to_clipboard(item.branch)
        vim.notify('Copied branch name: ' .. item.branch, L.INFO)
      end,
    },
    win = {
      input = {
        keys = {
          ['<C-f>'] = { 'diff_branches', mode = { 'i', 'n' } },
          ['<A-m>'] = { 'merge_branch', mode = { 'i', 'n' } },
          ['<A-d>'] = { 'delete_branch', mode = { 'i', 'n' } },
          ['<C-c>'] = { 'browse_branch_commits', mode = { 'i', 'n' } },
          ['<C-o>'] = { 'branch_history', mode = { 'i', 'n' } },
          ['<C-g>'] = { 'copy_branch', mode = { 'i', 'n' } },
        },
      },
    },
  }
end

function M.browse_branches()
  Snacks.picker.git_branches(
    vim.tbl_deep_extend('force', branch_overrides(), {})
  )
end

local function stash_overrides()
  return {
    actions = {
      view_stash_diff = function(picker, item)
        if not item then return end
        picker:close()
        if not ar.plugin_available('diffview.nvim') then return end
        local res = vim
          .system({
            'git',
            'ls-tree',
            '-r',
            item.stash .. '^3',
            '--name-only',
          }, { text = true })
          :wait()
        if res.code == 0 and (res.stdout or '') ~= '' then
          vim.ui.select(
            { 'Tracked files', 'Untracked files' },
            { prompt = 'Show...' },
            function(choice)
              if choice == 'Tracked files' then
                vim.cmd('DiffviewOpen ' .. item.stash .. '^..' .. item.stash)
              else
                vim.cmd(
                  'DiffviewOpen 4b825dc642cb6eb9a060e54bf8d69288fbee4904..'
                    .. item.stash
                    .. '^3'
                )
              end
            end
          )
        else
          vim.cmd('DiffviewOpen ' .. item.stash .. '^..' .. item.stash)
        end
      end,
      drop_stash = function(picker, item)
        if not item then return end
        Snacks.picker.util.cmd(
          { 'git', 'stash', 'drop', item.stash },
          function() picker:refresh() end,
          { cwd = item.cwd }
        )
      end,
    },
    win = {
      input = {
        keys = {
          ['<C-f>'] = { 'view_stash_diff', mode = { 'i', 'n' } },
          ['<A-d>'] = { 'drop_stash', mode = { 'i', 'n' } },
        },
      },
    },
  }
end

function M.list_stashes()
  Snacks.picker.git_stash(vim.tbl_deep_extend('force', stash_overrides(), {}))
end

return M
