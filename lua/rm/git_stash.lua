if not rvim then return end

local M = {}

local function telescope_stash_mappings(prompt_bufnr, map)
  local actions = require('telescope.actions')
  map('i', '<C-v>', function()
    local stash_key =
      require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
    actions.close(prompt_bufnr)
    vim.cmd(':DiffviewOpen ' .. stash_key .. '^..' .. stash_key)
  end)
  map('i', '<C-Del>', function()
    local stash_key =
      require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
    local action_state = require('telescope.actions.state')
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:delete_selection(function()
      local Job = require('plenary.job')
      Job:new({
        command = 'git',
        args = { 'stash', 'drop', stash_key },
        -- on_exit = function(j, return_val)
        --   print(vim.inspect(j:result()))
        -- end,
      }):sync()
    end)
  end)
  actions.select_default:replace(function(prompt)
    -- copy-pasted from telescope actions.git_apply_stash + added the reload_all() and changed apply to pop
    local action_state = require('telescope.actions.state')
    local utils = require('telescope.utils')

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
      -- utils.notify("actions.git_apply_stash", {
      --   msg = string.format("applied: '%s' ", selection.value),
      --   level = "INFO",
      -- })
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
  local pickers = require('telescope.pickers')
  local make_entry = require('telescope.make_entry')
  local finders = require('telescope.finders')
  local previewers = require('telescope.previewers')
  local conf = require('telescope.config').values

  opts.show_branch = vim.F.if_nil(opts.show_branch, true)
  opts.entry_maker =
    vim.F.if_nil(opts.entry_maker, make_entry.gen_from_git_stash(opts))

  pickers
    .new(opts, {
      prompt_title = 'Git Stash',
      finder = finders.new_oneshot_job(
        vim.tbl_flatten({
          'git',
          '--no-pager',
          'stash',
          'list',
        }),
        opts
      ),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry, _)
          export = entry.contents
          return {
            'sh',
            '-c',
            'git -c color.ui=always diff '
              .. entry.value
              .. '^..'
              .. entry.value
              .. ' | less -RS +0 --tilde',
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
