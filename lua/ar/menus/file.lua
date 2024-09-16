local M = {}

local function get_params(with_children)
  local folder = vim.fn.expand('%:h')
  local params = {}
  if with_children then
    params.search_dirs = { folder }
  else
    params.find_command =
      { 'rg', '--files', '--max-depth', '1', '--files', folder }
  end
  return params
end

function M.open_file_cur_dir(with_children)
  local params = get_params(with_children)
  require('telescope.builtin').find_files(params)
end

function M.live_grep_in_cur_dir(with_children)
  local params = get_params(with_children)
  require('telescope.builtin').live_grep(params)
end

function M.find_word_in_cur_dir(with_children)
  local params = get_params(with_children)
  require('telescope.builtin').grep_string(params)
end

local function to_file_path_in_project(full_path)
  local projects = ar.get_projects()
  if projects == nil then return end

  for _, project in pairs(projects) do
    if full_path:match('^' .. ar.escape_pattern(project)) then
      return {
        project,
        full_path:gsub('^' .. ar.escape_pattern(project .. '/'), ''),
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

function M.copy_file_path() ar.copy_to_clipboard(cur_file_path_in_project()) end

function M.quick_set_ft()
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

function M.search_code_deps()
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

function M.toggle_file_diff()
  -- remember which is the current window
  local cur_win = vim.api.nvim_get_current_win()

  -- some windows may not be in diff mode, these that I ignore in this function
  -- => check if any window is in diff mode
  local has_diff = false
  local wins = vim.api.nvim_list_wins()
  for _, win in pairs(wins) do
    has_diff = has_diff
      ---@diagnostic disable-next-line: redundant-return-value
      or vim.api.nvim_win_call(win, function() return vim.opt.diff:get() end)
  end

  if has_diff then
    vim.cmd('windo diffoff')
  else
    -- used to do a plain 'windo diffthis', but i want to exclude some window types
    for _, win in pairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_ft = vim.api.nvim_get_option_value('ft', { buf = buf })
      if
        not vim.tbl_contains({
          'NvimTree',
          'packer',
          'cheat40',
          'OverseerList',
          'aerial',
          'AgitatorTimeMachine',
        }, buf_ft)
      then
        vim.api.nvim_win_call(win, function() vim.cmd('diffthis') end)
      end
    end
    -- restore the original current window
    vim.api.nvim_set_current_win(cur_win)
  end
end

return M
