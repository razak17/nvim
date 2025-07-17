local enabled = ar_config.plugin.custom.smart_spelling.enable

if not ar or ar.none or not enabled then return end

-- Ref: https://git.sr.ht/~swaits/thethethe.nvim

local config = {
  delay_ms = 2000,
  custom = {
    insert_mode = [[
    cosnt:const
    ]],
    command_mode = [[
      W!:w!
      Q!:q!
      Wq:wq
      wQ:wq
      WQ:wq
    ]],
  },
}

local function parse_abbrev_line(line)
  local parts = {}
  for part in line:gmatch('[^:]+') do
    part = part:gsub('^%s*(.-)%s*$', '%1') -- trim whitespace
    table.insert(parts, part)
  end
  return parts
end

-- load abbreviations.dict
local function load_abbreviations()
  local dict = require('ar.dictionary')
  for line in dict:gmatch('([^\n]*)\n?') do
    local parts = parse_abbrev_line(line)
    if #parts == 2 and parts[1] and parts[2] then
      vim.cmd(string.format('inoreabbrev %s %s', parts[1], parts[2]))
    end
  end

  -- Add custom abbreviations
  for mode, abbrev in pairs(config.custom) do
    local cmd
    if mode == 'insert_mode' then cmd = 'inoreabbrev' end
    if mode == 'command_mode' then cmd = 'cnoreabbrev' end
    for line in abbrev:gmatch('([^\n]*)\n?') do
      local parts = parse_abbrev_line(line)
      if #parts == 2 and parts[1] and parts[2] then
        vim.cmd(string.format('%s %s %s', cmd, parts[1], parts[2]))
      end
    end
  end
end

ar.command('SmartSpellingLoad', function()
  vim.defer_fn(load_abbreviations, config.delay_ms)
  vim.notify(
    'Smart Spelling Abbreviations Reloaded',
    vim.log.levels.INFO,
    { title = 'Smart Spelling' }
  )
end, { desc = 'Load smart spelling abbreviations' })
