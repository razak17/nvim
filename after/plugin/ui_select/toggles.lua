if not rvim then return end

function rvim.mappings.notify(msg, type)
  vim.schedule(function() vim.notify(msg, type, { title = 'UI Toggles' }) end)
end
---@param opt string
local function toggle_opt(opt)
  local prev = vim.api.nvim_get_option_value(opt, {})
  local value
  if type(prev) == 'boolean' then value = not prev end
  vim.wo[opt] = value
  rvim.mappings.notify(string.format('%s %s', opt, rvim.bool2str(vim.wo[opt])))
end

--- Toggle laststatus=3|2|0
local function toggle_statusline()
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
  rvim.mappings.notify(string.format('statusline %s', status))
end

--- Toggle conceal=2|0
local function toggle_conceal()
  vim.opt_local.conceallevel = vim.opt_local.conceallevel:get() == 0 and 2 or 0
  rvim.mappings.notify(
    string.format('conceal %s', rvim.bool2str(vim.opt_local.conceallevel:get() == 2))
  )
end

--- Toggle conceal cursor=n|''
local function toggle_conceal_cursor()
  vim.opt_local.concealcursor = vim.opt_local.concealcursor:get() == 'n' and '' or 'n'
  rvim.mappings.notify(
    string.format('conceal cursor %s', rvim.bool2str(vim.opt_local.concealcursor:get() == ''))
  )
end
map('n', '<localleader>cl', toggle_conceal, { desc = 'toggle conceallevel' })
map('n', '<localleader>cc', toggle_conceal_cursor, { desc = 'toggle concealcursor' })

local toggle_options = {
  ['1. Toggle Aerial'] = 'AerialToggle',
  ['1. Toggle Wrap'] = function() toggle_opt('wrap') end,
  ['1. Toggle Cursorline'] = function() toggle_opt('cursorline') end,
  ['1. Toggle Spell'] = function() toggle_opt('spell') end,
  ['1. Toggle Statusline'] = toggle_statusline,
  ['2. Toggle Ccc'] = 'CccHighlighterToggle',
  ['3. Toggle Pick'] = 'CccPick',
  ['4. Toggle Cloak'] = 'CloakToggle',
  ['4. Toggle SpOnGeBoB'] = 'SpOnGeBoBtOgGlE',
  ['4. Toggle ZenMode'] = 'ZenMode',
  ['4. Toggle Lengthmatters'] = 'LengthmattersToggle',
  ['5. Insert UUID'] = function()
    require('uuid-nvim').toggle_highlighting()
    require('uuid-nvim').insert_v4()
  end,
}

local toggle_menu = function()
  rvim.create_select_menu('Toggle actions', toggle_options)() --> extra paren to execute!
end

map('n', '<leader>o', toggle_menu, { desc = '[t]oggle [a]ctions: open menu for toggle actions' })
