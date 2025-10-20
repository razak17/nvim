local fn = vim.fn

local M = {}

--------------------------------------------------------------------------------
-- Builtin
--------------------------------------------------------------------------------
function M.git_pull()
  ar.run_command('git', { 'pull', '--rebase', '--autostash' }, ar.reload_all)
end

function M.git_push() ar.run_command('git', { 'push' }, ar.reload_all) end

function M.fetch_origin() ar.run_command('git', { 'fetch', 'origin' }) end

function M.abort_merge() ar.run_command('git', { 'merge', '--abort' }) end

function M.continue_merge() ar.run_command('git', { 'merge', '--continue' }) end

local function revert_commit(commit_hash)
  commit_hash = commit_hash or 'HEAD'
  ar.run_command('git', { 'revert', '--no-edit', commit_hash }, ar.reload_all)
end

function M.revert_last_commit() revert_commit() end

function M.revert_specific_commit()
  vim.ui.input({ prompt = 'Enter commit hash to revert: ' }, function(input)
    if input ~= nil and input ~= '' then revert_commit(input) end
  end)
end

function M.undo_last_commit()
  ar.run_command('git', { 'reset', 'HEAD~1' }, ar.reload_all)
end

-- https://github.com/olimorris/dotfiles/blob/main/.config/nvim/lua/config/functions.lua#L11
function M.list_branches()
  local branches = fn.systemlist([[git branch 2>/dev/null]])
  local new_branch_prompt = 'Create new branch'
  table.insert(branches, 1, new_branch_prompt)

  vim.ui.select(branches, {
    prompt = 'Git branches',
  }, function(choice)
    if choice == nil then return end

    if choice == new_branch_prompt then
      vim.ui.input({ prompt = 'New branch name:' }, function(branch)
        if branch ~= nil then fn.systemlist('git checkout -b ' .. branch) end
      end)
    else
      fn.systemlist('git checkout ' .. choice)
    end
  end)
end

function M.do_stash()
  vim.ui.input(
    { prompt = 'Enter a name for the stash: ', kind = 'center_win' },
    function(input)
      if input ~= nil then
        ar.run_command(
          'git',
          { 'stash', 'push', '-m', input, '-u' },
          ar.reload_all
        )
      end
    end
  )
end

function M.do_stash_all()
  -- stylua: ignore
  vim.ui.input({ prompt = 'Enter a name for the stash: ', kind = 'center_win' }, function(input)
      if input ~= nil then
        -- untracked files are a mess with git stash: https://stackoverflow.com/a/12681856/516188
        -- just stage everything before stashing.
        -- stylua: ignore
        vim.system({ 'git', 'add', '.' }, { text = true }, vim.schedule_wrap(function()
          ar.run_command(
            'git', { 'stash', 'push', '-m', input, '-u' }, ar.reload_all
          )
        end))
      end
    end
  )
end

-- we could stash staged on unstaged, better staged, no mess with untracked files
function M.git_do_stash_staged()
  vim.ui.input({
    prompt = 'Enter a name for the stash (staged files only): ',
    kind = 'center_win',
  }, function(input)
    if input ~= nil then
      -- get the list of staged files
      local git_root = vim.fs.root(vim.fn.getcwd(), '.git')
      vim.system(
        { 'git', 'stash', 'push', '--staged', '-m', input },
        { text = true, cwd = git_root },
        vim.schedule_wrap(function() ar.reload_all() end)
      )
    end
  end)
end

return M
