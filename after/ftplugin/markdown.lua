if not ar or ar.none then return end

local api, cmd, fn, g = vim.api, vim.cmd, vim.fn, vim.g
local L = vim.log.levels
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
      vim.notify('URL image cannot be deleted from disk', L.WARN)
    else
      local absolute_image_path = get_absolute_path(image_path)
      if fn.confirm('Delete image file?', '&Yes\n&No') == 1 then
        local success, _ = pcall(
          function() ar.trash_file(fn.fnameescape(absolute_image_path)) end
        )
        if success then
          cmd([[lua require("image").clear()]])
          cmd('edit!')
        end
      end
    end
  else
    vim.notify('No image found under the cursor', L.WARN)
  end
end

-- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L524
local function refresh_images()
  cmd([[lua require("image").clear()]])
  cmd('edit!')
  print('Images refreshed')
end

-- Toggle bullet point at the beginning of the current line in normal mode
-- @see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L598
local function toggle_bullets()
  local cursor_pos = api.nvim_win_get_cursor(0)
  local current_buffer = api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  local line =
    api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
  if line:match('^%s*%-') then
    line = line:gsub('^%s*%-', '')
    api.nvim_buf_set_lines(
      current_buffer,
      start_row,
      start_row + 1,
      false,
      { line }
    )
    return
  end
  local left_text = line:sub(1, col)
  local bullet_start = left_text:reverse():find('\n')
  if bullet_start then bullet_start = col - bullet_start end
  local right_text = line:sub(col + 1)
  local bullet_end = right_text:find('\n')
  local end_row = start_row
  while
    not bullet_end and end_row < api.nvim_buf_line_count(current_buffer) - 1
  do
    end_row = end_row + 1
    local next_line =
      api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == '' then break end
    right_text = right_text .. '\n' .. next_line
    bullet_end = right_text:find('\n')
  end
  if bullet_end then bullet_end = col + bullet_end end
  local text_lines =
    api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
  local text = table.concat(text_lines, '\n')
  local new_text = '- ' .. text
  local new_lines = vim.split(new_text, '\n')
  api.nvim_buf_set_lines(
    current_buffer,
    start_row,
    end_row + 1,
    false,
    new_lines
  )
end

--@see: https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/config/keymaps.lua?plain=1#L572
local function delete_new_lines()
  local start_row = fn.line('v')
  local end_row = fn.line('.')
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end
  local current_row = start_row
  while current_row <= end_row do
    local line =
      api.nvim_buf_get_lines(0, current_row - 1, current_row, false)[1]
    if line == '' then
      cmd(current_row .. 'delete')
      end_row = end_row - 1
    else
      current_row = current_row + 1
    end
  end
end

local function bold_selection()
  local start_row, start_col = unpack(fn.getpos("'<"), 2, 3)
  local end_row, end_col = unpack(fn.getpos("'>"), 2, 3)
  local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected_text =
    table.concat(lines, '\n'):sub(start_col, #lines == 1 and end_col or -1)
  if selected_text:match('^%*%*.*%*%*$') then
    vim.notify('Text already bold', L.INFO)
  else
    cmd('normal 2gsa*')
  end
end

-- -- Multiline unbold attempt
-- -- In normal mode, bold the current word under the cursor
-- -- If already bold, it will unbold the word under the cursor
-- -- If you're in a multiline bold, it will unbold it only if you're on the
-- -- first line
local function multiline_bold()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(
    current_buffer,
    start_row,
    start_row + 1,
    false
  )[1]
  -- Check if the cursor is on an asterisk
  if line:sub(col + 1, col + 1):match('%*') then
    vim.notify('Cursor is on an asterisk, run inside the bold text', L.WARN)
    return
  end
  -- Search for '**' to the left of the cursor position
  local left_text = line:sub(1, col)
  local bold_start = left_text:reverse():find('%*%*')
  if bold_start then bold_start = col - bold_start end
  -- Search for '**' to the right of the cursor position and in following lines
  local right_text = line:sub(col + 1)
  local bold_end = right_text:find('%*%*')
  local end_row = start_row
  while
    not bold_end and end_row < api.nvim_buf_line_count(current_buffer) - 1
  do
    end_row = end_row + 1
    local next_line =
      api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == '' then break end
    right_text = right_text .. '\n' .. next_line
    bold_end = right_text:find('%*%*')
  end
  if bold_end then bold_end = col + bold_end end
  -- Remove '**' markers if found, otherwise bold the word
  if bold_start and bold_end then
    -- Extract lines
    local text_lines =
      api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
    local text = table.concat(text_lines, '\n')
    -- Calculate positions to correctly remove '**'
    -- vim.notify("bold_start: " .. bold_start .. ", bold_end: " .. bold_end)
    local new_text = text:sub(1, bold_start - 1)
      .. text:sub(bold_start + 2, bold_end - 1)
      .. text:sub(bold_end + 2)
    local new_lines = vim.split(new_text, '\n')
    -- Set new lines in buffer
    api.nvim_buf_set_lines(
      current_buffer,
      start_row,
      end_row + 1,
      false,
      new_lines
    )
  else
    -- Bold the word at the cursor position if no bold markers are found
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    local inside_surround = before:match('%*%*[^%*]*$')
      and after:match('^[^%*]*%*%*')
    if inside_surround then
      cmd('normal gsd*.')
    else
      cmd('normal viw')
      cmd('normal 2gsa*')
    end
    vim.notify('Bolded current word', L.INFO)
  end
end

-- In visual mode, surround the selected text with markdown link syntax
local function convert_to_link(new_tab)
  cmd("let @a = getreg('+')")
  cmd('normal d')
  cmd('startinsert')
  if new_tab then
    api.nvim_put({ '[](){:target="_blank"} ' }, 'c', true, true)
  else
    api.nvim_put({ '[]() ' }, 'c', true, true)
  end
  cmd('normal F[pf(')
  cmd('stopinsert')
end

-- Paste a github link and add it in this format
-- [folke/noice.nvim](https://github.com/folke/noice.nvim){:target="\_blank"}
local function paste_github_link()
  cmd('normal! a[](){:target="_blank"} ')
  cmd('normal! F(pv2F/lyF[p')
  cmd('stopinsert')
end

-- Generate/update a Markdown TOC
local function generate_toc()
  local path = fn.expand('%')
  local bufnr = 0
  cmd('mkview')
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local toc_exists = false -- Flag to check if TOC marker exists
  local frontmatter_end = 0 -- To store the end line number of frontmatter
  for i, line in ipairs(lines) do
    if i == 1 and line:match('^---$') then
      for j = i + 1, #lines do
        if lines[j]:match('^---$') then
          frontmatter_end = j -- Save the end line of the frontmatter
          break
        end
      end
    end
    if line:match('^%s*<!%-%-%s*toc%s*%-%->%s*$') then
      toc_exists = true -- Sets the flag if TOC marker is found
      break
    end
  end
  -- Inserts H1 heading and <!-- toc --> at the appropriate position
  if not toc_exists then
    if frontmatter_end > 0 then
      api.nvim_buf_set_lines(
        bufnr,
        frontmatter_end,
        frontmatter_end,
        false,
        { '', '# Contents', '<!-- toc -->' }
      )
    else
      -- Insert at the top if no frontmatter
      api.nvim_buf_set_lines(
        bufnr,
        0,
        0,
        false,
        { '# Contents', '<!-- toc -->' }
      )
    end
  end
  -- Silently save the file, in case TOC being created for first time (yes, you need the 2 saves)
  cmd('silent write')
  vim.system('markdown-toc -i ' .. path):wait()
  cmd('edit!')
  cmd('silent write')
  vim.notify('TOC updated and file saved', L.INFO)
  cmd('loadview')
end

-- Save the cursor position globally to access it across different mappings
ar.markdown = {
  saved_positions = {},
}

-- Mapping to jump to the first line of the TOC
local function go_to_toc()
  ar.markdown.saved_positions['toc_return'] = api.nvim_win_get_cursor(0)
  cmd('silent! /<!-- toc -->\\n\\n\\zs.*')
  cmd('nohlsearch')
  local cursor_pos = api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  api.nvim_win_set_cursor(0, { row, 14 })
end

-- Mapping to return to the previously saved cursor position
local function return_to_position()
  local pos = ar.markdown.saved_positions['toc_return']
  if pos then api.nvim_win_set_cursor(0, pos) end
end

-- Open current file in finder
local function open_in_file_manager()
  local file_path = fn.expand('%:p')
  ar.open_in_file_manager(file_path)
end

-- Open current file in Neovide
local function open_in_neovide()
  local file_path = fn.expand('%:p')
  if file_path ~= '' then
    vim.system({ 'neovide', file_path }):wait()
  else
    print('No file is currently open')
  end
end

local function with_desc(desc) return { buffer = 0, desc = fmt('%s', desc) } end

map(
  'n',
  '<leader>id',
  delete_image_under_cursor,
  with_desc('delete image under cursor')
)

map(
  'n',
  '<leader>io',
  open_image_under_cursor,
  with_desc('open image under cursor in preview')
)

map(
  { 'n', 'v' },
  '<leader>ip',
  paste_image_from_clipboard,
  with_desc('paste image from system clipboard')
)

map('n', '<leader>ir', refresh_images, with_desc('refresh images'))

map('n', '<leader><leader>md', toggle_bullets, with_desc('toggle bullet point'))

map(
  'v',
  '<localleader>mj',
  delete_new_lines,
  with_desc('delete newlines in selected text')
)

map('n', '<localleader>Pm', '<Cmd>Glow<CR>', with_desc('markdown preview'))

map('v', '<leader><leader>mb', bold_selection, with_desc('BOLD selection'))

map('n', '<leader><leader>mb', multiline_bold, with_desc('toggle BOLD markers'))

map('v', '<leader><leader>mll', convert_to_link, with_desc('convert to link'))

map(
  'v',
  '<leader><leader>mlt',
  function() convert_to_link(true) end,
  with_desc('convert to link (new tab)')
)

map('i', '<C-g>', paste_github_link, with_desc('paste github link'))

map('n', '<leader><leader>mt', generate_toc, with_desc('insert/update TOC'))

map('n', '<leader><leader>mm', go_to_toc, with_desc('jump to TOC'))

map(
  'n',
  '<leader>mn',
  return_to_position,
  with_desc('return to position before jumping')
)

map(
  'n',
  '<leader><leader>fo',
  open_in_file_manager,
  with_desc('open in finder')
)

map('n', '<leader><leader>fn', open_in_neovide, with_desc('open in neovide'))

ar.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('markdown', {
      sources = {
        { name = 'dictionary', max_item_count = 10, group_index = 1 },
        { name = 'spell', group_index = 1 },
        { name = 'emoji', group_index = 1 },
        { name = 'buffer', group_index = 2 },
        { name = 'rg', group_index = 2 },
        { name = 'natdat', group_index = 3 },
      },
    })
  end,
})
