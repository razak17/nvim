if not rvim then return end

local fn = vim.fn

local projects_file = fn.stdpath('data') .. '/project_nvim/project_history'

-- if you have a git project that has subfolders..
-- in a subfolder there is a package.json.. then vim-rooter
-- will set the cwd to that subfolder -- not the git repo root.
-- with this we get the actual git repo root.
local function cur_file_project_root()
  local full_path = fn.expand('%:p')
  for _, project in pairs(rvim.get_projects()) do
    if
      full_path:match('^' .. rvim.escape_pattern(project) .. '/')
      and fn.isdirectory(project .. '/.git') ~= 0
    then
      return project
    end
  end
  -- no project that matches, return the current folder
  return fn.getcwd()
end

local function is_git_repo()
  return fn.isdirectory(fn.expand('%:p:h') .. '/.git')
end

local function project_history()
  vim.cmd('DiffviewFileHistory ' .. cur_file_project_root())
end

local function time_machine()
  require('agitator').git_time_machine({ use_current_win = true })
end

local function git_pull()
  rvim.run_command(
    'git',
    { 'pull', '--rebase', '--autostash' },
    rvim.reload_all
  )
end

local function git_fetch_origin() rvim.run_command('git', { 'fetch', 'origin' }) end

-- Get project info for all (de)activated projects
function rvim.get_projects()
  local projects = {}
  for line in io.lines(projects_file) do
    table.insert(projects, line)
  end
  return projects
end

function rvim.git.diffview_conflict_view_commit(which)
  local merge_ctx = require('diffview.lib').get_current_view().merge_ctx
  if merge_ctx then rvim.git.show_commit(merge_ctx[which].hash) end
end

local git_options = {
  ['1. Show Branches'] = "lua require'telescope.builtin'.git_branches()",
  ['1. Browse Branches'] = 'lua rvim.git.browse_branches()',
  ['1. Stash Changes'] = 'lua rvim.git.do_stash()',
  ['1. Browse Stashes'] = 'lua rvim.git.list_stashes()',
  ['2. Browse Commits'] = 'lua rvim.git.browse_commits()',
  ['2. Show Buffer Commits'] = 'lua rvim.git.browse_bcommits()',
  ['2. Show Commit At Line'] = 'lua rvim.git.show_commit_at_line()',
  ['2. Display Commit From Hash'] = 'lua rvim.git.display_git_commit()',
  ['3. Open File From Branch'] = "lua require'agitator'.open_file_git_branch()",
  ['3. Search In Another Branch'] = "lua require'agitator'.search_git_branch()",
  ['4. Time Machine'] = time_machine,
  ['4. Project History'] = project_history,
  ['4. File History'] = 'DiffviewFileHistory %',
  ['5. Pull Latest Changes'] = git_pull,
  ['5. Fetch Orign'] = git_fetch_origin,
  ['6. Conflict Show Base'] = 'lua rvim.git.diffview_conflict_view_commit("base")',
  ['6. Conflict Show Ours'] = 'lua rvim.git.diffview_conflict_view_commit("ours")',
  ['6. Conflict Show Theirs'] = 'lua rvim.git.diffview_conflict_view_commit("theirs")',
}

local git_menu = function()
  if not is_git_repo() then
    vim.notify_once('Not a git directory')
  else
    rvim.create_select_menu('Git Commands', git_options)()
  end
end

map(
  'n',
  '<leader>ga',
  git_menu,
  { desc = '[g]it [a]ctions: open menu for git commands' }
)
