if not rvim then return end

local function open_file_cur_dir(with_children)
  local folder = vim.fn.expand('%:h')
  local params = {
    path_display = function(_, p)
      return string.gsub(p, rvim.escape_pattern(folder .. '/'), '')
    end,
  }
  if with_children then
    params.search_dirs = { folder }
  else
    params.find_command =
      { 'rg', '--files', '--max-depth', '1', '--files', folder }
  end
  require('telescope.builtin').find_files(params)
end

local function to_file_path_in_project(full_path)
  for _, project in pairs(rvim.get_projects()) do
    if full_path:match('^' .. rvim.escape_pattern(project)) then
      return {
        project,
        full_path:gsub('^' .. rvim.escape_pattern(project .. '/'), ''),
      }
    end
  end
  return nil
end

local function cur_file_path_in_project()
  local full_path = vim.fn.expand('%:p')
  local project_info = to_file_path_in_project(full_path)
  -- if no project that matches, return the relative path
  return project_info and project_info[2] or vim.fn.expand('%')
end

local function copy_file_path()
  rvim.copy_to_clipboard(cur_file_path_in_project())
end

local function quick_set_ft()
  local filetypes = {
    'typescript',
    'json',
    'elixir',
    'rust',
    'lua',
    'diff',
    'sh',
    'markdown',
    'html',
    'config',
    'sql',
    'other',
  }
  vim.ui.select(
    filetypes,
    { prompt = 'Pick filetype to switch to' },
    function(choice)
      if choice == 'other' then
        vim.ui.input(
          { prompt = 'Enter filetype', kind = 'center_win' },
          function(word)
            if word ~= nil then vim.cmd('set ft=' .. word) end
          end
        )
      elseif choice ~= nil then
        vim.cmd('set ft=' .. choice)
      end
    end
  )
end

local function search_code_deps()
  if vim.fn.isdirectory('node_modules') then
    require('telescope').extensions.live_grep_raw.live_grep_raw({
      cwd = 'node_modules',
    })
  else
    vim.cmd(
      [[echohl ErrorMsg | echo "Not handled for this project type" | echohl None]]
    )
  end
end

local function toggle_diff()
  -- remember which is the current window
  local cur_win = vim.api.nvim_get_current_win()

  -- some windows may not be in diff mode, these that I ignore in this function
  -- => check if any window is in diff mode
  local has_diff = false
  local wins = vim.api.nvim_list_wins()
  for _, win in pairs(wins) do
    has_diff = has_diff
      or vim.api.nvim_win_call(win, function() return vim.opt.diff:get() end)
  end

  if has_diff then
    vim.cmd('windo diffoff')
  else
    -- used to do a plain 'windo diffthis', but i want to exclude some window types
    for _, win in pairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_ft = vim.api.nvim_buf_get_option(buf, 'ft')
      if
        not vim.tbl_contains(
          { 'NvimTree', 'packer', 'cheat40', 'OverseerList', 'aerial' },
          buf_ft
        )
      then
        vim.api.nvim_win_call(win, function() vim.cmd('diffthis') end)
      end
    end
    -- restore the original current window
    vim.api.nvim_set_current_win(cur_win)
  end
end
-- 'stevearc/aerial.nvim'
local file_options = {
  ['1. Open File From Current Dir'] = function() open_file_cur_dir(false) end,
  ['2. Open File From Current Dir And Children'] = function()
    open_file_cur_dir(true)
  end,
  ['3. Reload All Files From Disk'] = 'lua rvim.reload_all()',
  ['4. Copy File Path'] = copy_file_path,
  ['4. Copy Full File Path'] = 'let @+ = expand("%:p")',
  ['4. Yank Last Ex Command'] = 'let @+=@:',
  ['4. Yank Last Message'] = [[let @+=substitute(execute('messages'), '\n\+', '\n', 'g')]],
  ['5. Change Filetype'] = quick_set_ft,
  ['6. Search Code Deps'] = search_code_deps,
  ['7. Toggle Diff'] = toggle_diff,
  ['8. Toggle Diff'] = toggle_diff,
  ['8. Re-open File With Sudo Permissions'] = 'SudaRead',
  ['8. Write File With Sudo Permissions'] = 'SudaWrite',
}

local file_menu = function()
  rvim.create_select_menu('File actions', file_options)()
end

map(
  'n',
  '<leader>fl',
  file_menu,
  { desc = '[f]ile [a]ctions: open menu for file actions' }
)
