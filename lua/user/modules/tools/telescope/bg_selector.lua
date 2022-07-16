local _, actions = pcall(require, 'telescope.actions')
local _, builtin = pcall(require, 'telescope.builtin')
local _, state = pcall(require, 'telescope.actions.state')

local bg_selector = {}

local function set_background(content) os.execute('xwallpaper --zoom ' .. content) end

local function select_background(prompt_bufnr, map)
  local function set_the_background(close)
    local content = state.get_selected_entry(prompt_bufnr)
    set_background(content.cwd .. '/' .. content.value)
    if close then actions.close(prompt_bufnr) end
  end

  map('i', '<C-y>', function() set_the_background() end)

  map('i', '<CR>', function() set_the_background(true) end)
end

local image_selector = function(prompt, cwd)
  return function()
    builtin.find_files({
      prompt_title = prompt,
      cwd = cwd,

      attach_mappings = function(prompt_bufnr, map)
        select_background(prompt_bufnr, map)
        return true
      end,
    })
  end
end

bg_selector.set_bg_image = image_selector('Choose Wallpaper', '$HOME/pics/distro')

return bg_selector
