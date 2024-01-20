---@diagnostic disable: param-type-mismatch
local M = {}

function M.open_db_common(db_name)
  vim.cmd([[tabnew]])
  vim.fn['db_ui#reset_state']()
  vim.b.dbui_db_key_name = db_name .. '_g:dbs'

  pcall(vim.cmd, 'DBUIFindBuffer') -- pcall, for nice error handling if the DB does not exist
  vim.cmd('DBUI')
  -- open the tables list and get back where i was
  vim.cmd('norm jjojjjjokkkkkk')
  -- go twice up and select "new buffer". didn't find a nicer way
  vim.cmd('norm kko')
end

---@param db_name string
function M.open_local_postgres_db(db_name)
  vim.g.dbs = {
    [db_name] = 'postgresql://postgres@localhost/' .. db_name,
  }
  vim.cmd([[tabnew]])
  vim.fn['db_ui#reset_state']()
  vim.b.dbui_db_key_name = db_name .. '_g:dbs'

  pcall(vim.cmd, 'DBUIFindBuffer') -- pcall, for nice error handling if the DB does not exist
  vim.cmd('DBUI')
  -- open the tables list and get back where i was
  vim.cmd('norm jjojjjjokkkkkk')
  -- go twice up and select "new buffer". didn't find a nicer way
  vim.cmd('norm kko')
end

function M.pick_local_pg_db()
  local db_names = {}
  vim.fn.jobstart(
    { 'sh', '-c', "psql -l | grep $(whoami) | awk '{print $1}'" },
    {
      on_stdout = vim.schedule_wrap(function(_, output)
        for _, line in ipairs(output) do
          table.insert(db_names, line)
        end
      end),
      on_exit = vim.schedule_wrap(function(_, _)
        vim.ui.select(
          db_names,
          { prompt = 'Pick the database to open', kind = 'center_win' },
          function(choice)
            if choice ~= nil then M.open_local_postgres_db(choice) end
          end
        )
      end),
    }
  )
end

function M.open_saved_query()
  local folder =
    string.gsub(vim.g.db_ui_save_location, '~', vim.loop.os_homedir())
  local sd = vim.loop.fs_scandir(folder)
  local saved_queries = {}
  while true do
    local name, type = vim.loop.fs_scandir_next(sd)
    if name == nil then break end
    if type == 'directory' then
      local nested_path = folder .. '/' .. name
      local nested_sd = vim.loop.fs_scandir(nested_path)
      while true do
        local nested_name, _ = vim.loop.fs_scandir_next(nested_sd)
        if nested_name == nil then break end
        table.insert(saved_queries, name .. '/' .. nested_name)
      end
    end
  end

  local pickers = require('telescope.pickers')
  local previewers = require('telescope.previewers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local putils = require('telescope.previewers.utils')
  local opts = {}

  pickers
    .new(opts, {
      prompt_title = 'Saved queries',
      finder = finders.new_table({
        results = saved_queries,
        entry_maker = function(val)
          local entry = {}
          entry.value = folder .. '/' .. val
          entry.ordinal = val
          entry.display = val
          return entry
        end,
      }),
      -- previewer = conf.file_previewer(opts),
      previewer = previewers.new_buffer_previewer({
        title = 'Query',

        get_buffer_by_name = function(_, entry) return entry.value end,

        define_preview = function(self, entry)
          conf.buffer_previewer_maker(entry.value, self.state.bufnr, {
            bufname = self.state.bufname,
            winid = self.state.winid,
            callback = function(bufnr) putils.highlighter(bufnr, 'sql') end,
          })
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, map)
        map('i', '<Cr>', function(prompt_bufnr)
          local filename =
            require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
          local Path = require('plenary.path')
          actions.close(prompt_bufnr)
          -- copy to the clipboard
          vim.fn.setreg('+', Path.new(filename):read())
        end)
        map('i', '<C-o>', function(prompt_bufnr)
          local filename =
            require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
          local Path = require('plenary.path')
          vim.fn.jobstart({ 'xdg-open', Path.new(filename):parent().filename })
        end)
        return true
      end,
    })
    :find()
end

function M.open_json()
  local db_name = vim.fn.expand('%')
  vim.g.dbs = {
    [db_name] = 'jq:' .. db_name,
  }
  M.open_db_common(db_name)
end

return M
