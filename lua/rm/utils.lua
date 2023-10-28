local M = {}

function M.show_commit(commit_sha)
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
  M.show_commit(commit_sha)
end

function M.telescope_commits_mappings(prompt_bufnr, _)
  local actions = require('telescope.actions')
  map('i', '<C-r>i', function()
    local commit =
      require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
    vim.cmd(':term! git rebase -i ' .. commit .. '~')
  end)
  map('i', '<C-v>', function()
    local commit =
      require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
    actions.close(prompt_bufnr)
    vim.cmd(':DiffviewOpen ' .. commit .. '^..' .. commit)
  end)
  return true
end

-- pasted and modified from telescope's lua/telescope/make_entry.lua
-- make_entry.gen_from_git_commits
function M.custom_make_entry_gen_from_git_commits(opts)
  local entry_display = require('telescope.pickers.entry_display')
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

return M