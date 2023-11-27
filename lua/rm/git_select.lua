local fn = vim.fn

local M = {}

local projects_file = fn.stdpath('data') .. '/project_nvim/project_history'

-- if you have a git project that has subfolders..
-- in a subfolder there is a package.json.. then vim-rooter
-- will set the cwd to that subfolder -- not the git repo root.
-- with this we get the actual git repo root.
local function cur_file_project_root()
  local full_path = fn.expand('%:p')
  for _, project in pairs(rvim.get_projects()) do
    if
      ---@diagnostic disable-next-line: param-type-mismatch
      full_path:match('^' .. rvim.escape_pattern(project) .. '/')
      and fn.isdirectory(project .. '/.git') ~= 0
    then
      return project
    end
  end
  -- no project that matches, return the current folder
  return fn.getcwd()
end

function M.project_history()
  vim.cmd('DiffviewFileHistory ' .. cur_file_project_root())
end

function M.time_machine()
  require('agitator').git_time_machine({ use_current_win = true })
end

function M.git_pull()
  rvim.run_command(
    'git',
    { 'pull', '--rebase', '--autostash' },
    rvim.reload_all
  )
end

function M.git_fetch_origin() rvim.run_command('git', { 'fetch', 'origin' }) end

-- Get project info for all (de)activated projects
function rvim.get_projects()
  local projects = {}
  for line in io.lines(projects_file) do
    table.insert(projects, line)
  end
  return projects
end

function M.diffview_conflict(which)
  local merge_ctx = require('diffview.lib').get_current_view().merge_ctx
  if merge_ctx then require('rm.utils').show_commit(merge_ctx[which].hash) end
end

return M
