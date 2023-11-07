if not rvim or rvim.none then return end

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
    string.format(
      'conceal %s',
      rvim.bool2str(vim.opt_local.conceallevel:get() == 2)
    )
  )
end

--- Toggle conceal cursor=n|''
local function toggle_conceal_cursor()
  vim.opt_local.concealcursor = vim.opt_local.concealcursor:get() == 'n' and ''
    or 'n'
  rvim.mappings.notify(
    string.format(
      'conceal cursor %s',
      rvim.bool2str(vim.opt_local.concealcursor:get() == '')
    )
  )
end
map('n', '<localleader>cl', toggle_conceal, { desc = 'toggle conceallevel' })
map(
  'n',
  '<localleader>cc',
  toggle_conceal_cursor,
  { desc = 'toggle concealcursor' }
)

local function toggle_sunglasses()
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

local toggle_options = {
  ['Toggle Aerial'] = 'AerialToggle',
  ['Toggle Wrap'] = function() toggle_opt('wrap') end,
  ['Toggle Cursorline'] = function() toggle_opt('cursorline') end,
  ['Toggle Spell'] = function() toggle_opt('spell') end,
  ['Toggle Statusline'] = toggle_statusline,
  ['Toggle Ccc'] = 'CccHighlighterToggle',
  ['Toggle Pick'] = 'CccPick',
  ['Toggle Cloak'] = 'CloakToggle',
  ['Toggle SpOnGeBoB'] = 'SpOnGeBoBtOgGlE',
  ['Toggle Lengthmatters'] = 'LengthmattersToggle',
  ['Toggle Twilight'] = 'Twilight',
  ['Toggle ZenMode'] = 'ZenMode',
  ['Toggle Sunglasses'] = toggle_sunglasses,
  ['Toggle Zoom'] = 'lua require("mini.misc").zoom()',
}

local toggle_menu = function()
  rvim.create_select_menu('Toggle actions', toggle_options)() --> extra paren to execute!
end

map(
  'n',
  '<leader>oo',
  toggle_menu,
  { desc = '[t]oggle [a]ctions: open menu for toggle actions' }
)
