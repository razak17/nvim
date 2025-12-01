local enabled = ar.config.plugin.custom.spell_all_good.enable

if not ar or ar.none or not enabled then return end

-- Enhanced spell good mapping
-- Ref: https://www.reddit.com/r/neovim/comments/1otjmh7/enhanced_spell_good_mapping/

local api, fn = vim.api, vim.fn

local function spell_all_good()
  local lines =
    fn.getregion(fn.getpos('v'), fn.getpos('.'), { type = fn.mode() })
  local spellfile = api.nvim_get_option_value('spellfile', { scope = 'local' })

  if spellfile == '' then return vim.notify('Aborted') end

  local spellfiles = vim.split(spellfile, ',')

  vim.ui.select(
    spellfiles,
    { prompt = 'Select spell file' },
    function(choice, i)
      if choice == nil then return end
      for _, line in ipairs(lines) do
        while true do
          local word, type = unpack(fn.spellbadword(line))
          if word == '' or type ~= 'bad' then break end
          vim.cmd(i .. 'spellgood ' .. word)
        end
      end
    end
  )

  -- exit visual mode
  local esc = api.nvim_replace_termcodes('<esc>', true, false, true)
  api.nvim_feedkeys(esc, fn.mode(), false)
end
map('x', 'zg', spell_all_good)

local function enhanced_spell_good()
  local cword = fn.expand('<cword>')
  local spellfile = api.nvim_get_option_value('spellfile', { scope = 'local' })

  if spellfile == '' then return vim.notify('Aborted') end

  vim.ui.input(
    { default = cword:lower(), prompt = 'spell good' },
    function(input)
      if not input then return vim.notify('Aborted') end
      input = vim.trim(input)
      if ar.falsy(input) then return end
      local spellfiles = vim.split(spellfile, ',')
      if #spellfiles == 1 then
        vim.cmd('spellgood ' .. input)
        return vim.notify('Added "' .. input .. '" to spellfile.')
      end
      vim.ui.select(
        spellfiles,
        { prompt = 'Select spell file' },
        function(choice, i)
          if choice == nil then return end
          vim.cmd(i .. 'spellgood ' .. input)
          vim.notify('Added "' .. input .. '" to spellfile.')
        end
      )
    end
  )
end
map('n', 'zg', enhanced_spell_good)
