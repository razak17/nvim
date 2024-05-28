local fn = vim.fn
local fmt = string.format

local utils = require('telescope.utils')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local entry_display = require('telescope.pickers.entry_display')
local strings = require('plenary.strings')
local Job = require('plenary.job')
local action_state = require('telescope.actions.state')

local M = {}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
-- if you have a git project that has subfolders..
-- in a subfolder there is a package.json.. then vim-rooter
-- will set the cwd to that subfolder -- not the git repo root.
-- with this we get the actual git repo root.

--- Create mappings
---@param mappings table
---@param map function
local function create_mappings(mappings, map)
  vim.iter(mappings):each(
    function(m) map(m[1], m[2], m[3], { desc = fmt('git: %s', m.desc or '') }) end
  )
end

local function cur_file_project_root()
  local projects = rvim.get_projects()
  local full_path = fn.expand('%:p')
  if projects == nil then return end

  for _, project in pairs(projects) do
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

-- https://github.com/emmanueltouzery/nvim_config/blob/main/lua/leader_shortcuts.lua#L331
local function telescope_commits_mappings(prompt_bufnr, map)
  local mappings = {
    -- https://github.com/fdschmidt93/dotfiles/blob/master/nvim/.config/nvim/lua/plugins/telescope/actions.lua
    -- Start
    {
      'i',
      '<C-l>r',
      function()
        actions.close(prompt_bufnr)
        local value = action_state.get_selected_entry().value
        vim.cmd('DiffviewOpen ' .. value .. '~1..' .. value)
      end,
      desc = 'diffview relative',
    },
    {
      'i',
      '<C-l>a',
      function()
        actions.close(prompt_bufnr)
        local value = action_state.get_selected_entry().value
        vim.cmd('DiffviewOpen ' .. value)
      end,
      desc = 'diffview relative',
    },
    {
      'i',
      '<C-l>u',
      function()
        actions.close(prompt_bufnr)
        local value = action_state.get_selected_entry().value
        local rev = utils.get_os_command_output(
          { 'git', 'rev-parse', 'upstream/master' },
          vim.loop.cwd()
        )[1]
        vim.cmd('DiffviewOpen ' .. rev .. ' ' .. value)
      end,
      desc = 'diffview upstream master',
    },
    {
      'i',
      '<C-l>r',
      function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local _, ret, stderr = utils.get_os_command_output({
          'git',
          'revert',
          selection.value,
        })
        if ret == -1 then
          vim.notify('Reset to HEAD: ' .. selection.value, vim.log.levels.INFO)
        else
          vim.notify(
            string.format(
              'Error when applying: %s. Git returned: "%s"',
              selection.value,
              table.concat(stderr, '  ')
            ),
            vim.log.levels.ERROR
          )
        end
      end,
      desc = 'revert commit',
    },
    -- End
    {
      'i',
      '<C-r>i',
      function()
        local commit = action_state.get_selected_entry(prompt_bufnr).value
        vim.cmd(':term! git rebase -i ' .. commit .. '~')
      end,
      desc = 'rebase selected commit',
    },
    {
      'i',
      '<C-v>',
      function()
        local commit = action_state.get_selected_entry(prompt_bufnr).value
        actions.close(prompt_bufnr)
        vim.cmd(':DiffviewOpen ' .. commit .. '^..' .. commit)
      end,
      desc = 'view commit',
    },
    {
      'i',
      '<C-f>',
      function(nr)
        local picker = action_state.get_current_picker(nr)

        local commits = {}
        for _, entry in ipairs(picker:get_multi_selection()) do
          table.insert(commits, entry.value)
        end
        if #commits == 0 then
          local commit = action_state.get_selected_entry(prompt_bufnr).value
          actions.close(prompt_bufnr)
          vim.cmd(':DiffviewOpen ' .. commit .. '^..' .. commit)
        elseif #commits ~= 2 then
          print('Must select two commits for diff')
        else
          actions.close(prompt_bufnr)
          vim.cmd(':DiffviewOpen ' .. commits[1] .. '^..' .. commits[2])
        end
      end,
      desc = 'diff two commits',
    },
  }

  create_mappings(mappings, map)
  return true
end

-- pasted and modified from telescope's lua/telescope/make_entry.lua
-- make_entry.gen_from_git_commits
local function custom_make_entry_gen_from_git_commits(opts)
  opts = opts or {}

  local displayer = entry_display.create({
    separator = ' ',
    -- hl_chars = { ["("] = "TelescopeBorder", [")"] = "TelescopeBorder" }, --
    items = {
      { width = 8 },
      { width = 16 },
      { width = 10 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    if entry.refs ~= nil then
      return displayer({
        { entry.value, 'TelescopeResultsIdentifier' },
        entry.auth,
        entry.date,
        { entry.refs .. ' ' .. entry.msg, 'TelescopeResultsVariable' },
      })
    else
      return displayer({
        { entry.value, 'TelescopeResultsIdentifier' },
        entry.auth,
        entry.date,
        entry.msg,
      })
    end
  end

  return function(entry)
    if entry == '' then return nil end

    -- no optional regex groups in lua https://stackoverflow.com/questions/26044905
    -- no repeat count... https://stackoverflow.com/questions/32884090/
    -- can't hardcode the number of chars in the author due to lua regex multibyte snafu
    local sha, auth, date, refs, msg = string.match(
      entry,
      '([^ ]+) (.+) (%d%d%d%d%-%d%d%-%d%d) (%([^)]+%)) (.+)'
    )
    if sha == nil then
      sha, auth, date, msg =
        string.match(entry, '([^ ]+) (.+) (%d%d%d%d%-%d%d%-%d%d) (.+)')
    end

    if not msg then
      sha = entry
      msg = '<empty commit message>'
    end

    return {
      value = sha,
      ordinal = sha .. ' ' .. msg,
      auth = auth,
      date = date,
      refs = refs,
      msg = msg,
      display = make_display,
      current_file = opts.current_file,
    }
  end
end

--------------------------------------------------------------------------------
-- Pull / Fetch
--------------------------------------------------------------------------------
function M.git_pull()
  rvim.run_command(
    'git',
    { 'pull', '--rebase', '--autostash' },
    rvim.reload_all
  )
end

function M.fetch_origin() rvim.run_command('git', { 'fetch', 'origin' }) end

--------------------------------------------------------------------------------
-- Commits
--------------------------------------------------------------------------------
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

function M.show_commit_at_line()
  local commit_sha = require('agitator').git_blame_commit_for_line()
  if commit_sha == nil then return end
  show_commit(commit_sha)
end

function M.time_machine()
  require('agitator').git_time_machine({ use_current_win = true })
end

function M.display_commit_from_hash()
  vim.ui.input(
    { prompt = 'Enter git commit id:', kind = 'center_win' },
    function(input)
      if input ~= nil then
        vim.cmd(':DiffviewOpen ' .. input .. '^..' .. input)
      end
    end
  )
end

local git_command = {
  'git',
  'log',
  '--pretty=tformat:%<(10)%h%<(16,trunc)%an %ad%d %s',
  '--date=short',
  '--',
  '.',
}

local layout_config = { width = 0.9, horizontal = { preview_width = 0.5 } }
local previewer = rvim.telescope.delta_opts().previewer

function M.browse_commits()
  require('telescope.builtin').git_commits({
    attach_mappings = telescope_commits_mappings,
    entry_maker = custom_make_entry_gen_from_git_commits(),
    git_command = git_command,
    layout_config = layout_config,
    previewer = previewer,
  })
end

function M.browse_bcommits()
  require('telescope.builtin').git_bcommits({
    attach_mappings = telescope_commits_mappings,
    entry_maker = custom_make_entry_gen_from_git_commits(),
    git_command = git_command,
    layout_config = layout_config,
    previewer = previewer,
  })
end

--------------------------------------------------------------------------------
-- Diff
--------------------------------------------------------------------------------
function M.project_history()
  local project_root = cur_file_project_root()
  if rvim.falsy(project_root) then return end
  vim.cmd('DiffviewFileHistory ' .. project_root)
end

function M.diffview_conflict(which)
  local merge_ctx = require('diffview.lib').get_current_view().merge_ctx
  if merge_ctx then show_commit(merge_ctx[which].hash) end
end

--------------------------------------------------------------------------------
-- Branches
--------------------------------------------------------------------------------
function M.open_file_from_branch() require('agitator').open_file_git_branch() end

function M.search_in_another_branch() require('agitator').search_git_branch() end

-- forked from https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__git.lua#L197 as of 9f50168

local match_whole = function(word)
  -- https://stackoverflow.com/a/32854326/516188
  return '%f[%w_]' .. word .. '%f[^%w_]'
end

-- https://github.com/emmanueltouzery/nvim_config/blob/main/lua/leader_shortcuts.lua#L364
local function telescope_branches_mappings(prompt_bufnr, map)
  local get_selected_entry = action_state.get_selected_entry

  local mappings = {
    {
      'i',
      '<C-f>',
      function(nr)
        local branches = {}
        local picker = action_state.get_current_picker(nr)
        for _, entry in ipairs(picker:get_multi_selection()) do
          table.insert(branches, entry.value)
        end

        local diffspec
        if #branches == 0 then
          local branch = action_state.get_selected_entry(prompt_bufnr).value
          actions.close(prompt_bufnr)
          -- heuristics.. will see if it works out
          if
            string.match(branch, 'develop')
            or string.match(branch, 'master')
            or string.match(branch, 'main')
          then
            -- i want to compare to develop. presumably i'm ahead, comparing behind
            diffspec = branch .. '...'
          else
            -- i want to compare with another branch which isn't develop. i'm probably
            -- on develop => presumably i'm behind, comparing ahead
            diffspec = '...' .. branch
          end
          vim.cmd(':DiffviewOpen ' .. diffspec)
        else
          actions.close(prompt_bufnr)
          vim.cmd(':DiffviewOpen ' .. branches[1] .. '...' .. branches[2])
        end
      end,
      desc = 'compare two branches',
    },
    {
      'i',
      '<C-enter>',
      function()
        local branch = get_selected_entry(prompt_bufnr).value
        local cmd_output = {}
        if string.match(branch, '^origin/') then
          actions.close(prompt_bufnr)
          fn.jobstart('git checkout ' .. branch:gsub('^origin/', ''), {
            stdout_buffered = true,
            on_stdout = vim.schedule_wrap(function(_, output)
              for _, line in ipairs(output) do
                if #line > 0 then table.insert(cmd_output, line) end
              end
            end),
            on_stderr = vim.schedule_wrap(function(_, output)
              for _, line in ipairs(output) do
                if #line > 0 then table.insert(cmd_output, line) end
              end
            end),
            on_exit = vim.schedule_wrap(function() vim.notify(cmd_output) end),
          })
        end
      end,
      desc = 'create local branch',
    },
    {
      'i',
      '<C-b>',
      function()
        local branch = get_selected_entry(prompt_bufnr).value
        local cmd_output = {}
        actions.close(prompt_bufnr)
        vim.fn.jobstart('git rebase ' .. branch, {
          stdout_buffered = true,
          on_stdout = vim.schedule_wrap(function(_, output)
            for _, line in ipairs(output) do
              if #line > 0 then table.insert(cmd_output, line) end
            end
          end),
          on_stderr = vim.schedule_wrap(function(_, output)
            for _, line in ipairs(output) do
              if #line > 0 then table.insert(cmd_output, line) end
            end
          end),
          on_exit = vim.schedule_wrap(function() vim.notify(cmd_output) end),
        })
      end,
      desc = 'rebase on another branch',
    },
    {
      'i',
      '<A-m>',
      function()
        local branch = action_state.get_selected_entry(prompt_bufnr).value
        local cmd_output = {}
        actions.close(prompt_bufnr)
        vim.fn.jobstart('git merge ' .. branch, {
          stdout_buffered = true,
          on_stdout = vim.schedule_wrap(function(_, output)
            for _, line in ipairs(output) do
              if #line > 0 then table.insert(cmd_output, line) end
            end
          end),
          on_stderr = vim.schedule_wrap(function(_, output)
            for _, line in ipairs(output) do
              if #line > 0 then table.insert(cmd_output, line) end
            end
          end),
          on_exit = vim.schedule_wrap(function() vim.notify(cmd_output) end),
        })
      end,
      desc = 'merge another branch',
    },
    {
      { 'n', 'i' },
      '<A-d>',
      function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        current_picker:delete_selection(function(selection)
          local branch = get_selected_entry(selection.bufnr).value
          if string.match(branch, '^origin/') then
            -- remote branch
            vim.ui.select({ 'Yes', 'No' }, {
              prompt = "Are you sure to delete the remote branch '"
                .. string.gsub(branch, '^origin/', '')
                .. "'?",
            }, function(choice)
              if choice == 'Yes' then
                Job
                  :new({
                    command = 'git',
                    args = {
                      'push',
                      'origin',
                      '--delete',
                      string.gsub(branch, '^origin/', ''),
                    },
                    on_exit = function(j, _) print(vim.inspect(j:result())) end,
                  })
                  :sync()
              end
            end)
          else
            -- local branch
            Job:new({
              command = 'git',
              args = { 'branch', '-D', branch },
              on_exit = function(j, _)
                -- prints the sha of the tip of the deleted branch, useful for a manual undo
                print(vim.inspect(j:result()))
              end,
            }):sync()
          end
        end)
      end,
      desc = 'delete branch (including remote)',
    },
    {
      'i',
      '<C-c>',
      function()
        local branch = get_selected_entry(prompt_bufnr).value
        actions.close(prompt_bufnr)
        require('telescope.builtin').git_commits({
          attach_mappings = telescope_commits_mappings,
          entry_maker = custom_make_entry_gen_from_git_commits(),
          git_command = {
            'git',
            'log',
            branch,
            '--pretty=tformat:%<(10)%h%<(16,trunc)%an %ad%d %s',
            '--date=short',
            '--',
            '.',
          },
          layout_config = { width = 0.9, horizontal = { preview_width = 0.5 } },
        })
      end,
      desc = 'commits',
    },
    {
      'i',
      '<C-h>',
      function()
        local branch = get_selected_entry(prompt_bufnr).value
        actions.close(prompt_bufnr)
        vim.cmd(
          'DiffviewFileHistory '
            .. cur_file_project_root()
            .. ' --range='
            .. branch
        )
      end,
      desc = 'history',
    },
    {
      'i',
      '<C-g>',
      function()
        local branch = get_selected_entry(prompt_bufnr).value
        rvim.copy_to_clipboard(branch)
      end,
      desc = 'copy branch name',
    },
  }

  create_mappings(mappings, map)
  return true
end

local function git_branches_with_base(base, opts)
  local format = '%(HEAD)'
    .. '%(refname)'
    .. '%(ahead-behind:origin/'
    .. base
    .. ')'
    .. '%(authorname)'
    .. '%(upstream:lstrip=2)'
    .. '%(committerdate:format-local:%Y/%m/%d %H:%M:%S)'
  local output = utils.get_os_command_output({
    'git',
    'for-each-ref',
    '--perl',
    '--format',
    format,
    '--sort',
    '-authordate',
    opts.pattern,
  }, opts.cwd)
  local show_remote_tracking_branches =
    vim.F.if_nil(opts.show_remote_tracking_branches, true)

  local results = {}
  local widths = {
    name = 0,
    authorname = 0,
    upstream = 0,
    committerdate = 0,
    ahead = 0,
    behind = 0,
  }
  local unescape_single_quote = function(v)
    return string.gsub(v, "\\([\\'])", '%1')
  end
  local parse_line = function(line)
    local fields = vim.split(string.sub(line, 2, -2), "''", {})
    local entry = {
      head = fields[1],
      refname = unescape_single_quote(fields[2]),
      ahead = unescape_single_quote(fields[3]):gsub(' .*$', ''),
      behind = unescape_single_quote(fields[3]):gsub('^.* ', ''),
      authorname = unescape_single_quote(fields[4]),
      upstream = unescape_single_quote(fields[5]),
      committerdate = fields[6],
    }
    local prefix
    if vim.startswith(entry.refname, 'refs/remotes/') then
      if show_remote_tracking_branches then
        prefix = 'refs/remotes/'
      else
        return
      end
    elseif vim.startswith(entry.refname, 'refs/heads/') then
      prefix = 'refs/heads/'
    else
      return
    end
    local index = 1
    if entry.head ~= '*' then index = #results + 1 end

    entry.name = string.sub(entry.refname, string.len(prefix) + 1)
    for key, value in pairs(widths) do
      widths[key] = math.max(value, strings.strdisplaywidth(entry[key] or ''))
    end
    if string.len(entry.upstream) > 0 then widths.upstream_indicator = 2 end
    table.insert(results, index, entry)
  end
  for _, line in ipairs(output) do
    parse_line(line)
  end
  if #results == 0 then return end

  local name_width = widths.name
  if name_width > 35 then name_width = 35 end
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 1 },
      { width = name_width },
      { width = 3 + widths.ahead + widths.behind },
      { width = widths.authorname },
      { width = widths.upstream_indicator },
      { width = widths.upstream },
      { width = widths.committerdate },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.head },
      { entry.name, 'TelescopeResultsIdentifier' },
      { '⇣' .. entry.behind .. ' ⇡' .. entry.ahead },
      { entry.authorname },
      { string.len(entry.upstream) > 0 and '=>' or '' },
      { entry.upstream, 'TelescopeResultsIdentifier' },
      { entry.committerdate },
    })
  end

  pickers
    .new(opts, {
      prompt_title = 'Git Branches',
      finder = finders.new_table({
        results = results,
        entry_maker = function(entry)
          entry.value = entry.name
          entry.ordinal = entry.name
          entry.display = make_display
          return make_entry.set_default_entry_mt(entry, opts)
        end,
      }),
      previewer = previewers.git_branch_log.new(opts),
      sorter = conf.file_sorter(opts),
      attach_mappings = function(_, map)
        actions.select_default:replace(actions.git_checkout)
        map({ 'i', 'n' }, '<c-t>', actions.git_track_branch)
        map({ 'i', 'n' }, '<c-r>', actions.git_rebase_branch)
        map({ 'i', 'n' }, '<c-a>', actions.git_create_branch)
        map({ 'i', 'n' }, '<c-s>', actions.git_switch_branch)
        map({ 'i', 'n' }, '<c-delete>', actions.git_delete_branch)
        map({ 'i', 'n' }, '<c-y>', actions.git_merge_branch)
        return true
      end,
    })
    :find()
end

local function git_branches(opts)
  -- the base will be develop if a develop branch exists, otherwise master.
  local develop_exists = false
  local master_exists = false
  local main_exists = false
  vim.fn.jobstart({ 'git', 'branch', '--list', 'develop', 'master', 'main' }, {
    stdout_buffered = true,
    on_stdout = vim.schedule_wrap(function(_, output)
      for _, line in ipairs(output) do
        if string.match(line, match_whole('develop')) then
          develop_exists = true
        elseif string.match(line, match_whole('master')) then
          master_exists = true
        elseif string.match(line, match_whole('main')) then
          main_exists = true
        end
      end
    end),
    on_exit = vim.schedule_wrap(function()
      if develop_exists then
        git_branches_with_base('develop', opts)
      elseif master_exists then
        git_branches_with_base('master', opts)
      elseif main_exists then
        git_branches_with_base('main', opts)
      end
    end),
  })
end

function M.browse_branches()
  git_branches({
    attach_mappings = telescope_branches_mappings,
    pattern = '--sort=-committerdate',
  })
end

--------------------------------------------------------------------------------
-- Stash
--------------------------------------------------------------------------------
-- https://github.com/emmanueltouzery/nvim_config/blob/main/lua/telescope_git_stash.lua#L4
local function telescope_stash_mappings(prompt_bufnr, map)
  local mappings = {
    {
      'i',
      'C-f',
      function()
        local stash_key = action_state.get_selected_entry(prompt_bufnr).value
        actions.close(prompt_bufnr)
        -- are there untracked files?
        local stdout, _, _ = utils.get_os_command_output({
          'git',
          'ls-tree',
          '-r',
          stash_key .. '^3',
          '--name-only',
        })
        if #stdout > 0 then
          vim.ui.select(
            { 'Tracked files', 'Untracked files' },
            { prompt = 'Show...' },
            function(choice)
              if choice == 'Tracked files' then
                vim.cmd(':DiffviewOpen ' .. stash_key .. '^..' .. stash_key)
              else
                -- https://stackoverflow.com/questions/40883798
                vim.cmd(
                  ':DiffviewOpen 4b825dc642cb6eb9a060e54bf8d69288fbee4904..'
                    .. stash_key
                    .. '^3'
                )
              end
            end
          )
        else
          vim.cmd(':DiffviewOpen ' .. stash_key .. '^..' .. stash_key)
        end
      end,
      desc = 'stash',
    },
    {
      'i',
      'C-Del',
      function()
        local stash_key = action_state.get_selected_entry(prompt_bufnr).value
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        current_picker:delete_selection(function()
          Job:new({
            command = 'git',
            args = { 'stash', 'drop', stash_key },
            on_exit = function(j, return_val)
              print(vim.inspect(j:result(), return_val))
            end,
          }):sync()
        end)
      end,
      desc = 'drop stash',
    },
  }

  create_mappings(mappings, map)

  actions.select_default:replace(function(prompt)
    -- copy-pasted from telescope actions.git_apply_stash + added the reload_all() and changed apply to pop
    local selection = action_state.get_selected_entry()
    if selection == nil then
      utils.__warn_no_selection('actions.git_apply_stash')
      return
    end
    actions.close(prompt)
    local _, ret, stderr = utils.get_os_command_output({
      'git',
      'stash',
      'pop',
      '--index',
      selection.value,
    })
    if ret == 0 then
      rvim.reload_all()
      utils.notify('actions.git_apply_stash', {
        msg = string.format("applied: '%s' ", selection.value),
        level = 'INFO',
      })
    else
      utils.notify('actions.git_apply_stash', {
        msg = string.format(
          "Error when applying: %s. Git returned: '%s'",
          selection.value,
          table.concat(stderr, ' ')
        ),
        level = 'ERROR',
      })
    end
  end)
  return true
end

function M.list_stashes(opts)
  opts = opts or {}

  opts.show_branch = vim.F.if_nil(opts.show_branch, true)
  opts.entry_maker =
    vim.F.if_nil(opts.entry_maker, make_entry.gen_from_git_stash(opts))

  pickers
    .new(opts, {
      prompt_title = 'Git Stash',
      finder = finders.new_oneshot_job(
        vim
          .iter({
            'git',
            '--no-pager',
            'stash',
            'list',
          })
          :flatten()
          :totable(),
        opts
      ),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry, _)
          export = entry.contents
          -- show stash, ignoring gitignored files, and including untracked files
          -- https://stackoverflow.com/a/76662742/516188
          -- https://stackoverflow.com/a/12681856/516188
          return {
            'sh',
            '-c',
            '(git -c color.ui=always diff '
              .. entry.value
              .. '^..'
              .. entry.value
              .. '; git -c color.ui=always show '
              .. entry.value
              .. '^3) | less -RS +0 --tilde',
          }
        end,
      }),
      sorter = conf.file_sorter(opts),
      attach_mappings = telescope_stash_mappings,
    })
    :find()
end

function M.do_stash()
  vim.ui.input(
    { prompt = 'Enter a name for the stash: ', kind = 'center_win' },
    function(input)
      if input ~= nil then
        rvim.run_command(
          'git',
          { 'stash', 'push', '-m', input, '-u' },
          rvim.reload_all
        )
      end
    end
  )
end

return M
