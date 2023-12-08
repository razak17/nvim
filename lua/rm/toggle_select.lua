local M = {}

local function mappings_notify(msg, type)
  vim.schedule(function() vim.notify(msg, type, { title = 'UI Toggles' }) end)
end

---@param opt string
function M.toggle_opt(opt)
  local prev = vim.api.nvim_get_option_value(opt, {})
  local value
  if type(prev) == 'boolean' then value = not prev end
  vim.wo[opt] = value
  mappings_notify(string.format('%s %s', opt, rvim.bool2str(vim.wo[opt])))
end

--- Toggle laststatus=3|2|0
function M.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = 'local'
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = 'global'
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = 'off'
  end
  mappings_notify(string.format('statusline %s', status))
end

--- Toggle conceal=2|0
function M.toggle_conceal()
  vim.opt_local.conceallevel = vim.opt_local.conceallevel:get() == 0 and 2 or 0
  mappings_notify(
    string.format(
      'conceal %s',
      rvim.bool2str(vim.opt_local.conceallevel:get() == 2)
    )
  )
end
-- stylua: ignore
map('n', '<localleader>cl', ':lua require"rm.toggle_select".toggle_conceal()', { desc = 'toggle conceallevel' })

--- Toggle conceal cursor=n|''
function M.toggle_conceal_cursor()
  vim.opt_local.concealcursor = vim.opt_local.concealcursor:get() == 'n' and ''
    or 'n'
  mappings_notify(
    string.format(
      'conceal cursor %s',
      rvim.bool2str(vim.opt_local.concealcursor:get() == '')
    )
  )
end
-- stylua: ignore
map( 'n', '<localleader>cc', ':lua require"rm.toggle_select".toggle_conceal_cursor()', { desc = 'toggle concealcursor' })

function Mtoggle_sunglasses()
  local success, _ = pcall(require, 'sunglasses')
  if not success then return end
  local is_shaded
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    is_shaded = require('sunglasses.window').get(winnr):is_shaded()
    if is_shaded then
      vim.cmd('SunglassesDisable')
      return
    end
  end
  vim.cmd('SunglassesEnable')
  vim.cmd('SunglassesOff')
end

---@param db_name string
function M.open_local_postgres_db(db_name)
  vim.g.dbs = {
    [db_name] = 'postgresql://postgres@localhost/' .. db_name,
  }
  vim.cmd([[tabnew]])
  vim.fn['db_ui#reset_state']()
  vim.b.dbui_db_key_name = db_name .. '_g:dbs'
  vim.cmd([[DBUIFindBuffer]])
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
      on_exit = vim.schedule_wrap(function()
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

return M
