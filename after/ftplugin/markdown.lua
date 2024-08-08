if not ar or ar.none then return end

local api, cmd, fn, g = vim.api, vim.cmd, vim.fn, vim.g
local fmt = string.format

vim.opt.spell = true
vim.b.formatting_disabled = not vim.startswith(fn.expand('%'), g.projects_dir)

cmd.iabbrev(':tup:', '👍')
cmd.iabbrev(':tdo:', '👎')
cmd.iabbrev(':smi:', '😊')
cmd.iabbrev(':sad:', '😔')

if not ar.plugins.enable or ar.plugins.minimal then return end

--- get the image path from the current line
---@return string
local function get_image_path()
  local line = api.nvim_get_current_line()
  local image_pattern = '%[.-%]%((.-)%)'
  local _, _, image_path = string.find(line, image_pattern)
  return image_path
end

--- check if the path is an http path
---@param path string
---@return boolean
local function is_http_path(path) return string.sub(path, 1, 4) == 'http' end

--- get absolute path
---@param path string
---@return string
local function get_absolute_path(path)
  local current_file_path = fn.expand('%:p:h')
  return fmt('%s/%s', current_file_path, path)
end

-- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L359
local function open_image_under_cursor()
  local image_path = get_image_path()
  if image_path then
    if is_http_path(image_path) then
      print("URL image, use 'gx' to open it in the default browser.")
    else
      local absolute_image_path = get_absolute_path(image_path)
      ar.open(absolute_image_path, true)
    end
  else
    vim.notify('No image found under the cursor')
  end
end

-- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L332
local function paste_image_from_clipboard()
  local pasted_image = require('img-clip').paste_image()
  if pasted_image then
    cmd('update')
    print('Image pasted and file saved')
    cmd([[lua require("image").clear()]])
  else
    print('No image pasted. File not updated.')
  end
end

-- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L449
local function delete_image_under_cursor()
  local image_path = get_image_path()
  if image_path then
    if is_http_path(image_path) then
      api.nvim_echo({
        { 'URL image cannot be deleted from disk.', 'WarningMsg' },
      }, false, {})
    else
      local absolute_image_path = get_absolute_path(image_path)
      if fn.executable('trash') == 0 then
        api.nvim_echo({
          { 'Trash utility not installed.', 'ErrorMsg' },
        }, false, {})
        return
      end
      vim.ui.input({
        prompt = 'Delete image file? (y/n) ',
      }, function(input)
        if input == 'y' or input == 'Y' then
          local success, _ = pcall(
            function()
              fn.system({ 'trash', fn.fnameescape(absolute_image_path) })
            end
          )
          if success then
            api.nvim_echo({
              { 'Image file deleted from disk:\n', 'Normal' },
              { absolute_image_path, 'Normal' },
            }, false, {})
            cmd([[lua require("image").clear()]])
            cmd('edit!')
          else
            api.nvim_echo({
              { 'Failed to delete image file:\n', 'ErrorMsg' },
              { absolute_image_path, 'ErrorMsg' },
            }, false, {})
          end
        else
          api.nvim_echo({ { 'Image deletion canceled.', 'Normal' } }, false, {})
        end
      end)
    end
  else
    api.nvim_echo(
      { { 'No image found under the cursor', 'WarningMsg' } },
      false,
      {}
    )
  end
end

map(
  'n',
  '<leader>id',
  delete_image_under_cursor,
  { desc = 'delete image under cursor', buffer = 0 }
)

map(
  'n',
  '<leader>io',
  open_image_under_cursor,
  { desc = 'open image under cursor in preview', buffer = 0 }
)

map(
  { 'n', 'v', 'i' },
  '<leader>ip',
  paste_image_from_clipboard,
  { desc = 'paste image from system clipboard, buffer = 0' }
)

map(
  'n',
  '<localleader>Pm',
  '<Cmd>Glow<CR>',
  { desc = 'markdown preview', buffer = 0 }
)

map(
  'n',
  '<localleader>Pi',
  '<Cmd>PasteImage<CR>',
  { desc = 'paste clipboard image', buffer = 0 }
)

ar.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('markdown', {
      sources = {
        { name = 'dictionary', max_item_count = 10, group_index = 1 },
        { name = 'spell', group_index = 1 },
        { name = 'emoji', group_index = 1 },
        { name = 'buffer', group_index = 2 },
      },
    })
  end,
})
