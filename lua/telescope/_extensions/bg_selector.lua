local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local state = require('telescope.actions.state')

local function set_background(content)
  os.execute("feh --bg-scale " .. content)
end

local function select_background(prompt_bufnr, map)
  local function set_the_background(close)
    local content = state.get_selected_entry(prompt_bufnr)
    set_background(content.cwd .. "/" .. content.value)
    if close then
      actions.close(prompt_bufnr)
    end
  end

  map('i', '<C-y>', function()
    set_the_background()
  end)

  map('i', '<CR>', function()
    set_the_background(true)
  end)
end

local image_selector = function(prompt, cwd)
  return function()
    builtin.find_files({
      prompt_title = prompt,
      cwd = cwd,

      attach_mappings = function(prompt_bufnr, map)
        select_background(prompt_bufnr, map)
        return true
      end
    })
  end
end

local bg_selector = image_selector("Choose Wallpaper", "~/pics")

return telescope.register_extension {exports = {bg_selector = bg_selector}}
