local M = {}

-- HUUUUUUUUUUUUUUUUUUUUUUUGE kudos and thanks to
-- https://github.com/hown3d for this function <3
M.substitute = function(cmd)
  cmd = cmd:gsub('%%', vim.fn.expand('%'))
  cmd = cmd:gsub('$fileBase', vim.fn.expand('%:r'))
  cmd = cmd:gsub('$filePath', vim.fn.expand('%:p'))
  cmd = cmd:gsub('$file', vim.fn.expand('%'))
  cmd = cmd:gsub('$dir', vim.fn.expand('%:p:h'))
  cmd = cmd:gsub('#', vim.fn.expand('#'))
  cmd = cmd:gsub('$altFile', vim.fn.expand('#'))
  cmd = cmd:gsub('$project_name', vim.fn.expand('%:t:r')) -- for consistency

  return cmd
end

M.run_code = function()
  local file_extension = vim.fn.expand('%:e')
  local selected_cmd = ''
  local term_cmd = 'bot 10 new | term '
  local supported_filetypes = {
    c = {
      default = 'gcc % -o $fileBase && $fileBase',
      debug = 'gcc -g % -o $fileBase && $fileBase',
    },
    cpp = {
      default = 'g++ % -o  $fileBase && $fileBase',
      debug = 'g++ -g % -o  $fileBase',
      competitive = 'g++ -std=c++17 -Wall -DAL -O2 % -o $fileBase && $fileBase',
    },
    cs = {
      default = 'dotnet run',
    },
    go = {
      default = 'go run %',
    },
    html = {
      default = 'firefox $filePath', -- NOTE: Change this based on your browser that you use
    },
    java = {
      default = 'java %',
    },
    jl = {
      default = 'julia %',
    },
    js = {
      default = 'node %',
      debug = 'node --inspect %',
    },
    lua = {
      default = 'lua %',
    },
    php = {
      default = 'php %',
    },
    pl = {
      default = 'perl %',
    },
    py = {
      default = 'python3 %',
    },
    r = {
      default = 'Rscript %',
    },
    rb = {
      default = 'ruby %',
    },
    rs = {
      default = 'rustc % && $fileBase',
    },
    ts = {
      default = 'tsc % && node $fileBase',
    },
  }

  if supported_filetypes[file_extension] then
    local choices = vim.tbl_keys(supported_filetypes[file_extension])

    if #choices == 0 then
      vim.notify(
        "It doesn't contain any command",
        vim.log.levels.WARN,
        { title = 'Code Runner' }
      )
    elseif #choices == 1 then
      selected_cmd = supported_filetypes[file_extension][choices[1]]
      vim.cmd(term_cmd .. M.substitute(selected_cmd))
    else
      vim.ui.select(choices, { prompt = 'Choose a command: ' }, function(choice)
        selected_cmd = supported_filetypes[file_extension][choice]
        if selected_cmd then vim.cmd(term_cmd .. M.substitute(selected_cmd)) end
      end)
    end
  else
    vim.notify(
      "The filetype isn't included in the list",
      vim.log.levels.WARN,
      { title = 'Code Runner' }
    )
  end
end

M.pick_eslint_config = function(callback)
  local cwd = vim.fn.getcwd()

  local ignored_dirs = {
    'node_modules',
    '.git',
    'dist',
    'build',
    'coverage',
  }

  -- Recursive finder that skips ignored directories
  local files = vim.fs.find(function(name, path)
    -- Skip ignored directories entirely
    for _, ignore in ipairs(ignored_dirs) do
      if path:find('/' .. ignore .. '/') then return false end
    end
    return name == 'eslint.config.js'
  end, { path = cwd, type = 'file', limit = math.huge })

  if not files or #files == 0 then
    vim.notify(
      'No eslint.config.js files found in current directory.',
      vim.log.levels.WARN
    )
    return
  end

  local display = {}
  for _, path in ipairs(files) do
    local rel = vim.fn.fnamemodify(path, ':.')
    table.insert(display, rel)
  end

  vim.ui.select(
    display,
    { prompt = 'Select which eslint.config.js to use:' },
    function(choice)
      if not choice then
        vim.notify('ESLint config selection cancelled.', vim.log.levels.INFO)
        return
      end

      local selected_path = cwd .. '/' .. choice
      vim.notify('Using ESLint config: ' .. selected_path, vim.log.levels.INFO)

      if callback then callback(selected_path) end
    end
  )
end

M.pick_biome_config = function(callback)
  local cwd = vim.fn.getcwd()

  local ignored_dirs = {
    'node_modules',
    '.git',
    'dist',
    'build',
    'coverage',
  }

  -- Recursive finder that skips ignored directories
  local files = vim.fs.find(function(name, path)
    -- Skip ignored directories entirely
    for _, ignore in ipairs(ignored_dirs) do
      if path:find('/' .. ignore .. '/') then return false end
    end
    return name == 'biome.json' or name == 'biome.jsonc'
  end, { path = cwd, type = 'file', limit = math.huge })

  if not files or #files == 0 then
    vim.notify(
      'No biome.json(c) files found in current directory.',
      vim.log.levels.WARN
    )
    return
  end

  local display = {}
  for _, path in ipairs(files) do
    local rel = vim.fn.fnamemodify(path, ':.')
    table.insert(display, rel)
  end

  vim.ui.select(
    display,
    { prompt = 'Select which biome.json(c) to use:' },
    function(choice)
      if not choice then
        vim.notify('Biome config selection cancelled.', vim.log.levels.INFO)
        return
      end

      local selected_path = cwd .. '/' .. choice
      vim.notify('Using Biome config: ' .. selected_path, vim.log.levels.INFO)

      if callback then callback(selected_path) end
    end
  )
end

M.detect_package_manager = function(root)
  -- Check for pnpm-lock.yaml
  if vim.fn.filereadable(root .. '/pnpm-lock.yaml') == 1 then return 'pnpm' end
  -- Check for yarn.lock
  if vim.fn.filereadable(root .. '/yarn.lock') == 1 then return 'yarn' end
  -- Check for package-lock.json or default to npm
  if vim.fn.filereadable(root .. '/package-lock.json') == 1 then
    return 'npm'
  end
  -- Check for bun.lockb
  if vim.fn.filereadable(root .. '/bun.lockb') == 1 then return 'bun' end
  -- Default to npm
  return 'npm'
end

M.lint_project = function(linter_type, cmd)
  linter_type = linter_type or 'eslint'
  local picker = linter_type == 'biome' and M.pick_biome_config
    or M.pick_eslint_config

  picker(function(config_path)
    local root = vim.fn.fnamemodify(config_path, ':h')
    local output = {}

    -- Auto-detect package manager if cmd not provided
    if not cmd then
      local pkg_manager = M.detect_package_manager(root)
      if linter_type == 'biome' then
        cmd = pkg_manager .. ' biome check .'
      else
        cmd = pkg_manager .. ' run lint'
      end
    end

    vim.notify('Running: ' .. cmd, vim.log.levels.INFO)

    vim.fn.jobstart(cmd, {
      cwd = root,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data then vim.list_extend(output, data) end
      end,
      on_stderr = function(_, data)
        if data then vim.list_extend(output, data) end
      end,
      on_exit = function()
        local qf_list = {}

        if linter_type == 'biome' then
          qf_list = M.parse_biome_output(output, root)
        else
          qf_list = M.parse_eslint_output(output, root)
        end

        if #qf_list == 0 then
          local msg = linter_type == 'biome' and ' No Biome issues found.'
            or ' No ESLint issues found.'
          vim.notify(msg, vim.log.levels.INFO)
          vim.fn.setqflist({})
          return
        end

        local title = linter_type == 'biome' and 'Biome' or 'ESLint'
        vim.fn.setqflist({}, ' ', { title = title, items = qf_list })
        vim.cmd('copen')
      end,
    })
  end)
end

M.parse_eslint_output = function(output, root)
  local qf_list = {}
  local current_file = nil

  for _, line in ipairs(output) do
    -- Skip info / empty lines
    if line:match('^>') or line:match('^info') or line:match('^$') then
      goto continue
    end

    -- File header lines
    if line:match('^%./') then
      current_file = line:match('^%./(.*)')
      goto continue
    end

    -- Messages: line:col  type: message
    local lnum, col, msg = line:match('^(%d+):(%d+)%s+(.*)')
    if lnum and col and msg and current_file then
      table.insert(qf_list, {
        filename = root .. '/' .. current_file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = msg,
      })
    end
    ::continue::
  end

  return qf_list
end

M.parse_biome_output = function(output, root)
  local qf_list = {}
  local current_error = nil

  for _, line in ipairs(output) do
    -- Skip empty lines, separator lines, and pnpm output
    if
      line:match('^%s*$')
      or line:match('^check ━')
      or line:match('^>')
      or line:match('ELIFECYCLE')
      or line:match('^Checked %d+ files')
      or line:match('^Found %d+ error')
    then
      goto continue
    end

    -- Biome error format: src/config/site.ts:1:1 assist/source/organizeImports  FIXABLE  ━━━━
    local file, lnum, col, category =
      line:match('^([^:]+):(%d+):(%d+)%s+([^━]+)%s+[━]+')
    if file and lnum and col and category then
      current_error = {
        filename = root .. '/' .. file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = category:gsub('%s+$', ''), -- trim trailing spaces
        type = 'W', -- default to warning
      }
      goto continue
    end

    -- Error message line: × The imports and exports are not sorted.
    if current_error and line:match('^%s*×%s+(.+)') then
      local msg = line:match('^%s*×%s+(.+)')
      current_error.text = current_error.text .. ': ' .. msg
      current_error.type = 'E' -- mark as error
      table.insert(qf_list, current_error)
      current_error = nil
      goto continue
    end

    -- Warning message line: ! Some warning message
    if current_error and line:match('^%s*!%s+(.+)') then
      local msg = line:match('^%s*!%s+(.+)')
      current_error.text = current_error.text .. ': ' .. msg
      table.insert(qf_list, current_error)
      current_error = nil
      goto continue
    end

    ::continue::
  end

  -- Add any remaining error that wasn't followed by a message
  if current_error then table.insert(qf_list, current_error) end

  return qf_list
end

return M
