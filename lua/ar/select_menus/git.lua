local fn = vim.fn
local fmt = string.format
local L = vim.log.levels

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
--- Create mappings
---@param mappings table
---@param map function
local function create_mappings(mappings, map)
  vim.iter(mappings):each(
    function(m) map(m[1], m[2], m[3], { desc = fmt('git: %s', m.desc or '') }) end
  )
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
        if not ar.plugin_available('diffview.nvim') then return end
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
        if not ar.plugin_available('diffview.nvim') then return end
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
        if not ar.plugin_available('diffview.nvim') then return end
        local value = action_state.get_selected_entry().value
        local rev = utils.get_os_command_output(
          { 'git', 'rev-parse', 'upstream/master' },
          vim.uv.cwd()
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
          vim.notify('Reset to HEAD: ' .. selection.value, L.INFO)
        else
          local error = ''
          if stderr then error = table.concat(stderr, ' ') end
          vim.notify(
            string.format(
              'Error when applying: %s. Git returned: "%s"',
              selection.value,
              error
            ),
            L.ERROR
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
        local commit = action_state.get_selected_entry().value
        vim.cmd(':term! git rebase -i ' .. commit .. '~')
      end,
      desc = 'rebase selected commit',
    },
    {
      'i',
      '<C-v>',
      function()
        local commit = action_state.get_selected_entry().value
        actions.close(prompt_bufnr)
        if not ar.plugin_available('diffview.nvim') then return end
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
        actions.close(prompt_bufnr)
        if not ar.plugin_available('diffview.nvim') then return end
        if #commits == 0 then
          local commit = action_state.get_selected_entry().value
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
    {
      'i',
      '<A-k>',
      function()
        local commit = action_state.get_selected_entry().value
        vim.cmd(':term! git cherry-pick ' .. commit)
      end,
      desc = 'cherry-pick commit',
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
-- Builtin
--------------------------------------------------------------------------------
function M.git_pull()
  ar.run_command('git', { 'pull', '--rebase', '--autostash' }, ar.reload_all)
end

function M.fetch_origin() ar.run_command('git', { 'fetch', 'origin' }) end

function M.abort_merge() ar.run_command('git', { 'merge', '--abort' }) end

function M.continue_merge() ar.run_command('git', { 'merge', '--continue' }) end

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

--------------------------------------------------------------------------------
-- Commits
--------------------------------------------------------------------------------

local git_command = {
  'git',
  'log',
  '--pretty=tformat:%<(10)%h %<(16,trunc)%an %ad%d %s',
  '--date=short',
  '--',
  vim.fs.root(vim.fn.getcwd(), '.git'),
}

local layout_config = { width = 0.9, horizontal = { preview_width = 0.5 } }

local function telescope_commits(opts)
  opts.entry_maker = custom_make_entry_gen_from_git_commits()
  local prompt_title = 'Git Commits'
  if opts.branch then prompt_title = fmt('Git Commits (%s)', opts.branch) end

  local function attach_mappings(_, map)
    actions.select_default:replace(actions.git_checkout)
    map({ 'i', 'n' }, '<c-r>m', actions.git_reset_mixed)
    map({ 'i', 'n' }, '<c-r>s', actions.git_reset_soft)
    map({ 'i', 'n' }, '<c-r>h', actions.git_reset_hard)
    return true
  end

  pickers
    .new(opts, {
      prompt_title = prompt_title,
      finder = finders.new_oneshot_job(opts.git_command, opts),
      previewer = opts.previewer,
      sorter = conf.file_sorter(opts),
      attach_mappings = attach_mappings,
    })
    :find()
end

function M.browse_commits(branch)
  local opts = {
    attach_mappings = telescope_commits_mappings,
    entry_maker = custom_make_entry_gen_from_git_commits(),
    git_command = git_command,
    layout_config = layout_config,
    previewer = ar.telescope.delta_opts().previewer,
  }
  if branch then opts.branch = branch end
  telescope_commits(opts)
end

function M.browse_bcommits()
  require('telescope.builtin').git_bcommits({
    attach_mappings = telescope_commits_mappings,
    entry_maker = custom_make_entry_gen_from_git_commits(),
    git_command = git_command,
    layout_config = layout_config,
    previewer = ar.telescope.delta_opts().previewer,
  })
end

--------------------------------------------------------------------------------
-- Branches
--------------------------------------------------------------------------------
-- forked from https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__git.lua#L197 as of 9f50168

-- https://stackoverflow.com/a/32854326/516188
local match_whole = function(word) return '%f[%w_]' .. word .. '%f[^%w_]' end

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
          local branch = action_state.get_selected_entry().value
          actions.close(prompt_bufnr)
          if not ar.plugin_available('diffview.nvim') then return end
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
      '<A-m>',
      function()
        local branch = action_state.get_selected_entry().value
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
          on_exit = vim.schedule_wrap(
            function() vim.notify(cmd_output[3] or cmd_output[2]) end
          ),
        })
      end,
      desc = 'merge another branch',
    },
    {
      'i',
      '<A-d>',
      function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local branch = get_selected_entry().value
        local prompt = "Are you sure you want to delete branch '"
          .. branch
          .. "'?"
        if string.match(branch, '^origin/') then
          prompt = "Are you sure you want to delete the remote branch '"
            .. string.gsub(branch, '^origin/', '')
            .. "'?"
        end
        vim.ui.select({ 'Yes', 'No' }, {
          prompt = prompt,
        }, function(choice)
          if choice ~= 'Yes' then return end
          current_picker:delete_selection(function()
            -- remote branch
            if string.match(branch, '^origin/') then
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
        end)
      end,
      desc = 'delete branch (including remote)',
    },
    {
      'i',
      '<C-c>',
      function()
        local branch = get_selected_entry().value
        actions.close(prompt_bufnr)
        M.browse_commits(branch)
      end,
      desc = 'browse branch commits',
    },
    {
      'i',
      '<C-o>',
      function()
        local branch = get_selected_entry().value
        actions.close(prompt_bufnr)
        if not ar.plugin_available('diffview.nvim') then return end
        vim.cmd(
          'DiffviewFileHistory '
            .. vim.fs.root(vim.fn.getcwd(), '.git')
            .. ' --range='
            .. branch
        )
      end,
      desc = 'branch history',
    },
    {
      'i',
      '<C-g>',
      function()
        local branch = get_selected_entry().value
        ar.copy_to_clipboard(branch)
        vim.notify('Copied branch name: ' .. branch, L.INFO)
      end,
      desc = 'copy branch name',
    },
  }

  create_mappings(mappings, map)
  return true
end

local function get_base_output(base, opts)
  local no_upstream = false

  -- stylua: ignore
  local function get_format_string(is_local)
    if is_local then
      return '%(HEAD)' .. '%(refname)' .. '%(authorname)' .. '%(upstream:lstrip=2)' .. '%(committerdate:format-local:%Y/%m/%d %H:%M:%S)'
    else
      return '%(HEAD)' .. '%(refname)' .. '%(ahead-behind:origin/' .. base .. ')' .. '%(authorname)' .. '%(upstream:lstrip=2)' .. '%(committerdate:format-local:%Y/%m/%d %H:%M:%S)'
    end
  end

  local function get_output(format)
    return utils.get_os_command_output({
      'git',
      'for-each-ref',
      '--perl',
      '--format',
      format,
      '--sort',
      '-authordate',
      opts.pattern,
    }, opts.cwd)
  end

  local output = get_output(get_format_string(false))

  if ar.falsy(output) then
    no_upstream = true
    output = get_output(get_format_string(true))
  end

  return output, no_upstream
end

local function get_line_entry(line, show_remote, no_upstream)
  local function unescape_single_quote(v)
    return string.gsub(v, "\\([\\'])", '%1')
  end

  local fields = vim.split(string.sub(line, 2, -2), "''", {})
  local entry = {
    head = fields[1],
    refname = unescape_single_quote(fields[2]),
    authorname = unescape_single_quote(fields[4]),
    upstream = unescape_single_quote(fields[5]),
    committerdate = fields[6],
  }

  if no_upstream then
    entry = {
      head = fields[1],
      refname = unescape_single_quote(fields[2]),
      authorname = unescape_single_quote(fields[3]),
      upstream = unescape_single_quote(fields[4]),
      committerdate = fields[5],
    }
  else
    entry.ahead = unescape_single_quote(fields[3]):gsub(' .*$', '')
    entry.behind = unescape_single_quote(fields[3]):gsub('^.* ', '')
  end

  local prefix
  if vim.startswith(entry.refname, 'refs/remotes/') then
    if show_remote then prefix = 'refs/remotes/' end
  elseif vim.startswith(entry.refname, 'refs/heads/') then
    prefix = 'refs/heads/'
  end

  if ar.falsy(prefix) then return nil end
  return entry, prefix
end

local function git_branches_with_base(base, opts)
  local output, no_upstream = get_base_output(base, opts)

  local show_remote_tracking_branches =
    vim.F.if_nil(opts.show_remote_tracking_branches, true)

  local widths = {
    name = 0,
    authorname = 0,
    upstream = 0,
    committerdate = 0,
    ahead = 0,
    behind = 0,
  }

  local results = {}
  local index = 1

  for _, line in ipairs(output) do
    local entry, prefix =
      get_line_entry(line, show_remote_tracking_branches, no_upstream)
    if entry == nil or prefix == nil then goto continue end
    if entry.head ~= '*' then index = #results + 1 end

    entry.name = string.sub(entry.refname, string.len(prefix) + 1)
    for key, value in pairs(widths) do
      widths[key] = math.max(value, strings.strdisplaywidth(entry[key] or ''))
    end
    if string.len(entry.upstream) > 0 then widths.upstream_indicator = 2 end
    table.insert(results, index, entry)
    ::continue::
  end

  if #results == 0 then return end

  local name_width = widths.name
  if name_width > 35 then name_width = 35 end
  local displayer = entry_display.create({
    separator = ' ',
    items = no_upstream and {
      { width = 1 },
      { width = name_width },
      { width = widths.authorname },
      { width = widths.committerdate },
    } or {
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
    if no_upstream then
      return displayer({
        { entry.head },
        { entry.name, 'TelescopeResultsIdentifier' },
        { entry.authorname },
        { entry.committerdate },
      })
    end
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

  local function finder()
    return finders.new_table({
      results = results,
      entry_maker = function(entry)
        entry.value = entry.name
        entry.ordinal = entry.name
        entry.display = make_display
        return make_entry.set_default_entry_mt(entry, opts)
      end,
    })
  end

  local function attach_mappings(_, map)
    actions.select_default:replace(actions.git_checkout)
    map({ 'i', 'n' }, '<c-t>', actions.git_track_branch)
    map({ 'i', 'n' }, '<c-r>', actions.git_rebase_branch)
    map({ 'i', 'n' }, '<c-a>', actions.git_create_branch)
    map({ 'i', 'n' }, '<c-s>', actions.git_switch_branch)
    map({ 'i', 'n' }, '<c-delete>', actions.git_delete_branch)
    map({ 'i', 'n' }, '<c-y>', actions.git_merge_branch)
    return true
  end

  pickers
    .new(opts, {
      prompt_title = 'Search branch',
      results_title = 'Git Branches',
      finder = finder(),
      sorter = conf.file_sorter(opts),
      previewer = previewers.git_branch_log.new(opts),
      attach_mappings = attach_mappings,
    })
    :find()
end

local function git_branches(opts)
  local branches = {
    develop = false,
    dev = false,
    staging = false,
    master = false,
    main = false,
  }

  vim.fn.jobstart(
    { 'git', 'branch', '--list', unpack(vim.tbl_keys(branches)) },
    {
      stdout_buffered = true,
      on_stdout = vim.schedule_wrap(function(_, output)
        for _, line in ipairs(output) do
          for branch in pairs(branches) do
            if string.match(line, match_whole(branch)) then
              branches[branch] = true
            end
          end
        end
      end),
      on_exit = vim.schedule_wrap(function()
        for branch, exists in pairs(branches) do
          if exists then
            git_branches_with_base(branch, opts)
            break
          end
        end
      end),
    }
  )
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
      '<C-f>',
      function()
        local stash_key = action_state.get_selected_entry().value
        actions.close(prompt_bufnr)
        if not ar.plugin_available('diffview.nvim') then return end
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
      desc = 'view stash diff',
    },
    {
      'i',
      '<A-d>',
      function()
        local stash_key = action_state.get_selected_entry().value
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        current_picker:delete_selection(function()
          Job:new({
            command = 'git',
            args = { 'stash', 'drop', stash_key },
            -- on_exit = function(j, return_val)
            --   print(vim.inspect(j:result(), return_val))
            -- end,
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
      ar.reload_all()
      utils.notify('actions.git_apply_stash', {
        msg = string.format("applied: '%s' ", selection.value),
        level = 'INFO',
      })
    else
      local error = ''
      if stderr then error = table.concat(stderr, ' ') end
      utils.notify('actions.git_apply_stash', {
        msg = string.format(
          "Error when applying: %s. Git returned: '%s'",
          selection.value,
          error
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

  local function finder()
    return finders.new_oneshot_job(
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
    )
  end

  local function previewer()
    return previewers.new_termopen_previewer({
      get_command = function(entry, _)
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
    })
  end

  pickers
    .new(opts, {
      prompt_title = 'Search Stash',
      results_title = 'Git Stashes',
      finder = finder(),
      previewer = previewer(),
      sorter = conf.file_sorter(opts),
      attach_mappings = telescope_stash_mappings,
    })
    :find()
end

return M
