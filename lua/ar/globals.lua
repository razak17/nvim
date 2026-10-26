if not ar then return end

local fn, api, cmd, fmt = vim.fn, vim.api, vim.cmd, string.format
local L = vim.log.levels

function ar.sync_dir(path)
  return fmt('%s/Notes/%s', fn.expand('$SYNC_DIR'), path)
end

--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------

---@return string
function ar.norm(path)
  if path:sub(1, 1) == '~' then
    local home = vim.uv.os_homedir()
    if not home or home == '' then return path end
    if home:sub(-1) == '\\' or home:sub(-1) == '/' then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub('\\', '/'):gsub('/+', '/')
  return path:sub(-1) == '/' and path:sub(1, -2) or path
end

--  find string in list
function ar.find_string(table, string)
  local found = false
  for _, v in pairs(table) do
    if v == string then
      found = true
      break
    end
  end
  return found
end

function ar.char_on_pos(pos)
  pos = pos or fn.getpos('.')
  return tostring(fn.getline(pos[1])):sub(pos[2], pos[2])
end

-- From: https://neovim.discourse.group/t/how-do-you-work-with-strings-with-multibyte-characters-in-lua/2437/4
function ar.char_byte_count(s, i)
  if not s or s == '' then return 1 end

  local char = string.byte(s, i or 1)

  -- Get byte count of unicode character (RFC 3629)
  if char > 0 and char <= 127 then
    return 1
  elseif char >= 194 and char <= 223 then
    return 2
  elseif char >= 224 and char <= 239 then
    return 3
  elseif char >= 240 and char <= 244 then
    return 4
  end
end

-- https://github.com/Wansmer/nvim-config/blob/main/lua/utils.lua?plain=1#L83
function ar.get_visual_range()
  local sr, sc = unpack(fn.getpos('v'), 2, 3)
  local er, ec = unpack(fn.getpos('.'), 2, 3)

  -- To correct work with non-single byte chars
  local byte_c = ar.char_byte_count(ar.char_on_pos({ er, ec }))
  ec = ec + (byte_c - 1)

  local range = {}

  if sr == er then
    local cols = sc >= ec and { ec, sc } or { sc, ec }
    range = { sr, cols[1] - 1, er, cols[2] }
  elseif sr > er then
    range = { er, ec - 1, sr, sc }
  else
    range = { sr, sc - 1, er, ec }
  end

  return range
end

function ar.get_visual_text()
  local a_orig = fn.getreg('a')
  local mode = fn.mode()
  if mode ~= 'v' and mode ~= 'V' then cmd([[normal! gv]]) end

  cmd([[normal! "aygv]])
  local text = fn.getreg('a')
  fn.setreg('a', a_orig)
  return text
end

-- https://www.reddit.com/r/neovim/comments/1kig7rc/shorten_git_branch_name/
function ar.abbreviate(name, sign)
  sign = sign or '.'
  local s = name:gsub('[-_.]', ' ')
  local first_char = string.sub(name, 1, 1)
  s = s:gsub('(%l)(%u)', '%1 %2')
  local parts = {}
  for word in s:gmatch('%S+') do
    parts[#parts + 1] = word
  end
  local letters = {}
  for _, w in ipairs(parts) do
    local end_index = w:len() < 4 and w:len() or 3
    letters[#letters + 1] = w:sub(1, end_index):lower()
  end
  if first_char == '-' or first_char == '_' or first_char == '.' then
    -- if the first char is any of -_., prepend it
    return first_char .. table.concat(letters, sign)
  end
  return table.concat(letters, sign)
end

---@param callback function
---@param opts { forward: boolean }
---@return function
function ar.demicolon_jump(callback, opts)
  return function() require('demicolon.jump').repeatably_do(callback, opts) end
end

---@param callback function
---@param opts { forward: boolean }
---@return function
function ar.repeatable_jump(callback, opts)
  local repeat_move = require('repeatable_move').make_repeatable_move_pair
  local next_repeat, prev_repeat = repeat_move(
    function() callback({ forward = true }) end,
    function() callback({ forward = false }) end
  )
  return opts.forward and next_repeat or prev_repeat
end

---@param callback function
---@param opts { forward: boolean }
---@return function
function ar.jump(callback, opts)
  return function()
    local has_demicolon, has_repeatable

    if ar.package_manager == 'lazy' then
      has_demicolon = ar.has('demicolon.nvim')
      has_repeatable = ar.has('repeatable-move.nvim')
    end
    if ar.package_manager == 'vim.pack' then
      has_demicolon = package.loaded['demicolon']
      has_repeatable = package.loaded['repeatable_move']
    end

    if has_demicolon then return ar.demicolon_jump(callback, opts)() end
    if has_repeatable then return ar.repeatable_jump(callback, opts)() end
    return callback(opts)
  end
end

--- Remove duplicates from a table
---@param t table
---@return table
function ar.unique(t)
  return vim.iter(t):fold({}, function(acc, v)
    if not vim.tbl_contains(acc, v) then table.insert(acc, v) end
    return acc
  end)
end

function ar.mergeTables(destination, source)
  for k, v in pairs(source) do
    if type(v) == 'table' and type(v[1]) == 'string' then
      for _, item in ipairs(v) do
        for _, existing in ipairs(destination[k]) do
          if existing == item then goto continue end
        end
        table.insert(destination[k], item)
        ::continue::
      end
    elseif type(v) == 'table' then
      if destination[k] == nil or type(destination[k]) ~= 'table' then
        destination[k] = {}
      end
      ar.mergeTables(destination[k], v)
    else
      destination[k] = v
    end
  end
end

--- check for project local config
function ar.project_config(config, file)
  if not file then return end
  local json = file:read('*a')
  local status, table = pcall(fn.json_decode, json)
  io.close(file)
  if not status then
    cmd("echohl ErrorMsg | echo 'Error: Invalid json' | echohl None")
    vim.notify('Invalid json found in .rvim.json', 'error')
    return
  end
  ar.mergeTables(config, table)
end

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param minheight number
---@param maxheight number
function ar.adjust_split_height(minheight, maxheight)
  local line = fn.line('$') -- Assuming fn.line('$') returns an integer or nil

  if not line then line = 0 end

  api.nvim_win_resize(0, -1, math.max(math.min(line, maxheight), minheight))
end

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg? string
---@param func function
---@param ... any
---@return boolean, any
---@overload fun(func: function, ...): boolean, any
function ar.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func
    args, func, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    if ar.config.debug.enable then
      msg = debug.traceback(
        msg and fmt('%s:\n%s\n%s', msg, vim.inspect(args), err) or err
      )
      vim.schedule(function() vim.notify(msg, L.ERROR, { title = 'ERROR' }) end)
    end
  end, unpack(args))
end

---Check if a target directory exists in a given table
---@param dir string
---@param dirs_table table
---@return boolean
function ar.dirs_match(dirs_table, dir)
  for _, v in ipairs(dirs_table) do
    if dir:match(v) then return true end
  end
  return false
end

local cache = {} ---@type table<(fun()), table<string, any>>
---@generic T: fun()
---@param f T
---@return T
function ar.memoize(f)
  return function(...)
    local key = vim.inspect({ ... })
    cache[f] = cache[f] or {}
    if cache[f][key] == nil then cache[f][key] = f(...) end
    return cache[f][key]
  end
end

---@param name string
function ar.get_plugin(name)
  return require('lazy.core.config').spec.plugins[name]
end

---@param name string
function ar.opts(name)
  local plugin = ar.get_plugin(name)
  if not plugin then return {} end
  local Plugin = require('lazy.core.plugin')
  return Plugin.values(plugin, 'opts', false)
end

-- Check if a plugin is disabled
---@param plugin string The plugin to search for.
---@return boolean disabled # Whether the plugin is disabled.
function ar.plugin_disabled(plugin)
  return vim.tbl_contains(ar.config.plugins.disabled, plugin)
end

-- Get a plugin's enable condition
---@param plugin string The plugin to search for.
---@param cond boolean # Other conditions to check.
---@return boolean disabled # Whether the plugin is disabled.
function ar.get_plugin_cond(plugin, cond)
  local disabled = ar.plugin_disabled(plugin)
  local override = ar.config.plugins.override
  if vim.tbl_contains(override, plugin) and not disabled then return true end
  if not ar.falsy(override) then return vim.tbl_contains(override, plugin) end
  if disabled then return false end
  if cond == nil then cond = true end
  return cond
end

function ar.lsp_enabled(which, what)
  local override = ar.config.lsp.override
  if not ar.falsy(override) then return vim.tbl_contains(override, what) end
  return ar.config.lsp.lang[which][what]
end

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.lazy_has(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  if not lazy_config_avail then return false end
  return lazy_config.plugins[plugin] ~= nil
end

---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.has(plugin)
  if ar.package_manager == 'lazy' then return ar.lazy_has(plugin) end
  if ar.package_manager == 'vim.pack' then return ar.pack.has(plugin) end
  return false
  -- return ar.lazy_has(plugin)
end

---@param plugin string The plugin to search for.
---@param notify boolean to show notification
---@return boolean available # Whether the plugin is available.
function ar.plugin_available(plugin, notify)
  if not ar.has(plugin) then
    if notify then
      vim.notify(
        fmt('%s is not available', plugin),
        L.INFO,
        { title = 'Plugins' }
      )
    end
    return false
  end
  return true
end

--- Check if a plugin is loaded
---@param plugin string The plugin to search for.
---@return boolean loaded # Whether the plugin is loaded.
function ar.is_loaded(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  if not lazy_config_avail then return false end
  return lazy_config.plugins[plugin] and lazy_config.plugins[plugin]._.loaded
end

-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua?plain=1#L307local _defaults = {} ---@type table<string, boolean>

local _defaults = {} ---@type table<string, boolean>

-- Determines whether it's safe to set an option to a default value.
--
-- It will only set the option if:
-- * it is the same as the global value
-- * it's current value is a default value
-- * it was last set by a script in $VIMRUNTIME
---@param option string
---@param value string|number|boolean
---@return boolean was_set
function ar.set_default(option, value)
  local l = api.nvim_get_option_value(option, { scope = 'local' })
  local g = api.nvim_get_option_value(option, { scope = 'global' })

  _defaults[('%s=%s'):format(option, value)] = true
  local key = ('%s=%s'):format(option, l)

  local source = ''
  if l ~= g and not _defaults[key] then
    -- Option does not match global and is not a default value
    -- Check if it was set by a script in $VIMRUNTIME
    local info = vim.api.nvim_get_option_info2(option, { scope = 'local' })
    local scriptinfo = vim.tbl_filter(
      ---@param e vim.fn.getscriptinfo.ret
      function(e) return e.sid == info.last_set_sid end,
      vim.fn.getscriptinfo()
    )
    source = scriptinfo[1] and scriptinfo[1].name or ''
    local by_rtp = #scriptinfo == 1
      and vim.startswith(scriptinfo[1].name, vim.fn.expand('$VIMRUNTIME'))
    if not by_rtp then
      if ar.config.debug.enable then
        vim.notify(
          ('Not setting option `%s` to `%q` because it was changed by a plugin.'):format(
            option,
            value
          ),
          { title = 'rVim', once = true },
          vim.log.levels.WARN
        )
      end
      return false
    end
  end

  if ar.config.debug.enable then
    vim.notify({
      ('Setting option `%s` to `%q`'):format(option, value),
      ('Was: %q'):format(l),
      ('Global: %q'):format(g),
      source ~= '' and ('Last set by: %s'):format(source) or '',
      'buf: ' .. api.nvim_buf_get_name(0),
    }, { title = 'rVim', once = true }, vim.log.levels.ERROR)
  end

  api.nvim_set_option_value(option, value, { scope = 'local' })
  return true
end

-- Ref: https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/util/init.lua?plain=1#L250
--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function ar.get_pkg_path(pkg, path, opts)
  pcall(require, 'mason') -- make sure Mason is loaded. Will fail when generating docs
  local root = vim.env.MASON or (fn.stdpath('data') .. '/mason')
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ''
  local ret = root .. '/packages/' .. pkg .. '/' .. path
  if opts.warn and not vim.loop.fs_stat(ret) then
    vim.notify(
      ('Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package.'):format(
        pkg,
        path
      ),
      L.WARN,
      { title = 'Mason' }
    )
  end
  return ret
end

-- Check if a lsp is disabled
---@param lsp string The lsp to search for.
---@return boolean disabled # Whether the lsp is disabled.
function ar.lsp_disabled(lsp)
  return vim.tbl_contains(ar.config.lsp.disabled.servers, lsp)
end

-- Check if a lsp is disabled in a directory
---@param dir string The directory to search for.
---@return boolean disabled # Whether the lsp is disabled.
function ar.dir_lsp_disabled(dir)
  return ar.dirs_match(ar.config.lsp.disabled.directories, fmt('%s', dir))
end

function ar.reload_all()
  cmd('checktime')
  vim.schedule(
    function() api.nvim_exec_autocmds('User', { pattern = 'GitStatusChanged' }) end
  )
end

-- Ref: https://github.com/serranomorante/dotfiles/blob/main/nvim/dot-config/nvim/lua/serranomorante/utils.lua?plain=1#L186
---Simple setTimeout wrapper
---@param timeout integer
---@param interval integer
---@param callback function
function ar.set_timeout(timeout, interval, callback)
  local timer = vim.uv.new_timer()
  if not timer then return end
  timer:start(timeout, interval, vim.schedule_wrap(callback))
  return timer
end

--- Run a command
---@param command table
---@param exit_cb? function
---@param start_cb? function
function ar.run_command(command, exit_cb, start_cb)
  if start_cb then start_cb() end
  vim.system(
    command,
    { text = true, cwd = vim.fs.root(vim.fn.getcwd(), '.git') },
    vim.schedule_wrap(function(res)
      if res.code == 0 then
        vim.notify(command[1] .. ' executed successfully', L.INFO)
        if exit_cb then exit_cb() end
      else
        local info = { command[1] .. ' failed!' }
        if res.stderr ~= nil then
          table.insert(info, res.stderr)
          print(res.stderr)
        end
        vim.notify(info, L.ERROR)
      end
    end)
  )
  vim.notify(command[1] .. ' launched...', L.INFO)
end

--- vim.cmd in visual mode
---@param command string
function ar.visual_cmd(command)
  -- Save the current state of visual selection
  local start_pos = fn.getpos("'<")
  local end_pos = fn.getpos("'>")
  -- Exit visual mode
  api.nvim_feedkeys(
    api.nvim_replace_termcodes('<Esc>', true, false, true),
    'x',
    false
  )
  local range = fmt('%d,%d', start_pos[2], end_pos[2])
  local full_cmd = fmt(':%s%s', range, command)
  cmd(full_cmd)
end

---@alias SelectMenuOptions 'ai' | 'command_palette' | 'git' | 'lsp' | 'toggle'

--- Add options to select menu
---@param name SelectMenuOptions
---@param options table
function ar.add_to_select(name, options)
  ar.select[name].options = ar.select[name].options or {}
  ar.select[name].options =
    vim.tbl_extend('force', ar.select[name].options, options)
end

function ar.escape_pattern(text) return text:gsub('([^%w])', '%%%1') end

--- copy some text to clipboard
---@param to_copy string
---@param msg? string | boolean
function ar.copy_to_clipboard(to_copy, msg)
  fn.setreg('+', to_copy, 'V')
  if msg == false then return end
  msg = msg or 'Copied to clipboard'
  vim.notify(msg, vim.log.levels.INFO)
end

function ar.load_colorscheme(name)
  return ar.pcall('theme failed to load because', cmd.colorscheme, name)
end

---@param path string
---@return boolean
function ar.has_git(path)
  path = path or fn.expand('%:p:h')
  return not ar.falsy(fn.isdirectory(fmt('%s/.git', path)))
end

-- Check if root directory is a git repo
---@param path string
---@return boolean
function ar.is_git_repo(path)
  path = path or fn.expand('%:p:h')
  return not ar.has_git(fn.isdirectory(fmt('%s/.git', path)))
    or not ar.falsy(vim.b.gitsigns_head)
    or not ar.falsy(vim.b.gitsigns_status_dict)
end

---@param path string
---@return boolean
function ar.is_git_worktree(path)
  path = path or fn.expand('%:p:h')
  return not ar.falsy(fn.filereadable(fmt('%s/.git', path)))
end

-- Check if git environment variables are set
---@return boolean
function ar.is_git_env() return vim.env.GIT_WORK_TREE and vim.env.GIT_DIR end

---@generic T:table<string, any>
---@param t T the object to format
---@param k string the key to format
---@return T?
function ar.format_text(t, k)
  local txt = (t and t[k]) and t[k]:gsub('%s', '') or ''
  if #txt < 1 then return end
  t[k] = txt
  return t
end

--[[ create_select_menu()
-- Create a menu to execute a Vim command or Lua function using vim.ui.select()
-- Example usage:
-- local options = {
--   [1. Onedark ] = "colo onedark"
--   [2. Tokyonight ] = function() vim.cmd("colo tokyonight") end
-- }
-- local colo_picker = util.create_select_menu("Choose a colorscheme", options)
-- vim.api.nvim_create_user_command("ColoPicker", colo_picker, { nargs = 0 })
--
-- @arg prompt: the prompt to display
-- @arg options_table: Table of the form { [n. Display name] = lua-function/vim-cmd, ... }
--                    The number is used for the sorting purpose and will be replaced by vim.ui.select() numbering
--]]
-- Ref: https://github.com/theopn/theovim/blob/d6b7debb00d5465b7165140db3699630a9f0e0d9/lua/tools/terminal.lua#L25
---@param prompt string
---@param options_table table
---@return function
function ar.create_select_menu(prompt, options_table)
  local frecency = require('ar.frecency')
  local option_names = vim.tbl_keys(options_table)
  if ar.config.frecency.enable then
    frecency.initialize()
    table.sort(option_names, function(a, b)
      local a_score = frecency.calc_frecency(a)
      local b_score = frecency.calc_frecency(b)
      return a_score > b_score
    end)
  else
    table.sort(option_names)
  end
  -- Return the prompt function. These global function var will be used when assigning keybindings
  local menu = function()
    vim.ui.select(option_names, {
      prompt = prompt,
      format_item = function(item) return item:gsub('%d. ', '') end,
    }, function(choice, item)
      local action = options_table[choice]
      if action ~= nil then
        if ar.config.frecency.enable then
          frecency.update_item(option_names[item], { prompt = prompt })
        end
        if type(action) == 'string' then
          cmd(action)
        elseif type(action) == 'function' then
          action()
        end
      end
    end)
  end
  return menu
end

--------------------------------------------------------------------------------
--  vim.pack
--------------------------------------------------------------------------------

--- Check if a plugin is available in vim.pack
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.pack.has(plugin)
  local has_config, pack_config = pcall(
    vim.pack.get,
    { plugin },
    { info = false }
  )
  if not has_config then return false end
  local has = false
  if pack_config and pack_config[1] then has = true end
  return has
end

--- Load a plugin on command execution or completion, then use its real command.
---@param name string|string[]
---@param load? fun()
---@return fun() cleanup Removes only command stubs still owned by this call.
function ar.pack.cmd(name, load)
  if type(name) == 'table' then
    local cleanups = {}
    for _, command in ipairs(name) do
      cleanups[#cleanups + 1] = ar.pack.cmd(command, load)
    end
    return function()
      for _, cleanup in ipairs(cleanups) do
        cleanup()
      end
    end
  end
  local invoke
  local function cleanup()
    local command = api.nvim_get_commands({})[name]
    if command and command.callback == invoke then
      api.nvim_del_user_command(name)
    end
  end
  local function load_command()
    cleanup()
    if load then load() end
    assert(
      fn.exists(':' .. name) == 2,
      'Plugin did not define command: ' .. name
    )
  end
  invoke = function(info)
    load_command()
    local range = ''
    if info.range == 1 then
      range = tostring(info.line2)
    elseif info.range == 2 then
      range = info.line1 .. ',' .. info.line2
    end
    -- Parse after loading so nargs, count, and escaping follow the real command.
    local command = api.nvim_parse_cmd(
      range .. name .. (info.bang and '!' or '') .. ' ' .. info.args,
      {}
    )
    command.mods = info.smods
    -- Let the command apply its default count without creating an explicit range.
    if info.range == 0 then command.count = nil end
    api.nvim_cmd(command, {})
    if command.nextcmd ~= '' then vim.cmd(command.nextcmd) end
  end
  api.nvim_create_user_command(name, invoke, {
    nargs = '*',
    bang = true,
    range = true,
    -- Counts may exceed the number of lines; the real command validates addresses.
    addr = 'other',
    complete = function(_, cmdline, cursorpos)
      load_command()
      return fn.getcompletion(cmdline:sub(1, cursorpos), 'cmdline')
    end,
  })
  return cleanup
end

---@alias PackDependency PackSpec

---@class PackKey
---@field [1] string
---@field [2] string|fun()
---@field mode? string|string[]
---@field desc? string
---@field noremap? boolean
---@field silent? boolean

---@class PackSpec
---@field src string
---@field load? boolean Forwarded to native package loading; false skips plugin scripts.
---@field name? string
---@field version? string|vim.VersionRange
---@field dev? boolean Load from ar.pack.dev.path instead of installing from src.
---@field lazy? boolean Defaults to ar.pack.defaults.lazy.
---@field init? fun():nil
---@field build? string|string[]|fun(args: AutocmdArgs):nil
---@field build_wait? boolean Wait for command builds before setup; defaults to true.
---@field build_timeout? integer Command timeout in milliseconds; defaults to 300000.
---@field cond? boolean|fun():boolean
---@field cmd? string|string[]
---@field ft? string|string[]
---@field setup? fun():nil
---@field dependencies? PackDependency[]
---@field keys? PackKey[]|fun(load: fun()):PackKey[]|nil
---@field event? string|string[]

local dev_package_root

---@param spec PackSpec|PackDependency
local function load_dev(spec)
  local name = spec.src:gsub('/+$', ''):match('([^/]+)$')
  assert(name, 'Invalid dev plugin source: ' .. spec.src)
  name = name:gsub('%.git$', '')
  local path = vim.fs.joinpath(vim.fn.expand(ar.pack.dev.path), name)
  local resolved = vim.uv.fs_realpath(path)
  if not resolved or vim.fn.isdirectory(resolved) ~= 1 then
    error('Dev plugin directory not found: ' .. path)
  end

  if not dev_package_root then
    dev_package_root = vim.fn.tempname()
    vim.fn.mkdir(
      vim.fs.joinpath(dev_package_root, 'pack', 'ar-dev', 'opt'),
      'p'
    )
    vim.opt.packpath:prepend(dev_package_root)
  end
  -- A unique package name avoids matching an installed remote package.
  local package_name = 'ar-dev-' .. vim.fn.sha256(resolved)
  local link =
    vim.fs.joinpath(dev_package_root, 'pack', 'ar-dev', 'opt', package_name)
  if not vim.uv.fs_lstat(link) then
    local ok, err = vim.uv.fs_symlink(resolved, link, { dir = true })
    assert(ok, err)
  end
  vim.cmd.packadd({ package_name, bang = spec.load == false })
end

---@param spec PackSpec|PackDependency
---@return boolean
local function check_condition(spec)
  if type(spec.cond) == 'function' then spec.cond = spec.cond() end
  if spec.cond == nil then spec.cond = true end
  return spec.cond
end

local pack_states, loading_path = {}, {}

---@param spec PackSpec|PackDependency
local function load_spec(spec)
  if ar.pack.loaded[spec.src] then return end
  local state = pack_states[spec.src]
  if state and state.status == 'failed' then error(state.error, 0) end
  if state and state.status == 'loading' then
    error(
      'Circular plugin load: '
        .. table.concat(loading_path, ' -> ')
        .. ' -> '
        .. spec.src,
      0
    )
  end
  if not check_condition(spec) then return end
  spec = state and state.spec or spec
  state = state or {}
  pack_states[spec.src] = state
  state.status = 'loading'
  loading_path[#loading_path + 1] = spec.src
  local ok, err = xpcall(function()
    local cleanups = state.cleanups or {}
    state.cleanups = nil
    for _, cleanup in ipairs(cleanups) do
      cleanup()
    end
    for _, dep in ipairs(spec.dependencies or {}) do
      load_spec(dep)
    end
    if spec.dev then
      load_dev(spec)
    else
      vim.pack.add(
        { { src = spec.src, name = spec.name, version = spec.version } },
        { confirm = false, load = spec.load }
      )
    end
    if spec.build and not spec.dev then
      local builds = require('ar.pack_build')
      builds.ensure(spec)
      if type(spec.build) == 'function' or spec.build_wait ~= false then
        builds.wait(spec.src)
      end
    end
    if spec.setup then spec.setup() end
    for _, restore in ipairs(state.keymaps or {}) do
      restore()
    end
  end, debug.traceback)
  state.keymaps = nil
  loading_path[#loading_path] = nil
  if not ok then
    state.status, state.error = 'failed', err
    error(err, 0)
  end
  state.status = 'loaded'
  ar.pack.loaded[spec.src] = true
end

local function event_groups(event)
  local groups = {}
  for _, autocmd in ipairs(api.nvim_get_autocmds({ event = event })) do
    if autocmd.group then groups[autocmd.group] = true end
  end
  return groups
end

local function replay_event(event, existing_groups)
  if
    not api.nvim_buf_is_valid(event.buf)
    or not api.nvim_buf_is_loaded(event.buf)
  then
    return
  end
  local groups, seen = {}, {}
  for _, autocmd in ipairs(api.nvim_get_autocmds({ event = event.event })) do
    local group = autocmd.group
    if group and not existing_groups[group] and not seen[group] then
      groups[#groups + 1], seen[group] = group, true
    end
  end
  for _, group in ipairs(groups) do
    if
      not api.nvim_buf_is_valid(event.buf)
      or not api.nvim_buf_is_loaded(event.buf)
    then
      return
    end
    -- An earlier handler may have deleted the next group.
    local ok, handlers =
      pcall(api.nvim_get_autocmds, { event = event.event, group = group })
    if ok and #handlers > 0 then
      local opts = { group = group, data = event.data, modeline = false }
      local buffer_match = event.match == api.nvim_buf_get_name(event.buf)
        or (event.event == 'FileType' and event.match == vim.bo[event.buf].filetype)
        or (event.event == 'Syntax' and event.match == vim.bo[event.buf].syntax)
      if buffer_match then
        opts.buffer = event.buf
        api.nvim_exec_autocmds(event.event, opts)
      else
        -- User, CmdlineEnter, ModeChanged, etc. match something other than a file.
        opts.pattern = event.match
        local function execute() api.nvim_exec_autocmds(event.event, opts) end
        if api.nvim_get_current_buf() == event.buf then
          execute()
        else
          api.nvim_buf_call(event.buf, execute)
        end
      end
    end
  end
end

---@param load fun()
---@return fun() cancel
local function on_very_lazy(load)
  local active, autocmd = true, nil
  local function schedule_load()
    vim.schedule(function()
      if not active or vim.v.exiting ~= vim.NIL then return end
      load()
    end)
  end

  if vim.v.vim_did_enter == 1 then
    schedule_load()
  else
    autocmd = vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = schedule_load,
    })
  end
  return function()
    active = false
    if autocmd then pcall(api.nvim_del_autocmd, autocmd) end
  end
end

local function global_keymap(mode, lhs)
  local expand = api.nvim_replace_termcodes
  local target = expand(lhs, true, true, true)
  for _, mapping in ipairs(api.nvim_get_keymap(mode)) do
    if expand(mapping.lhs, true, true, true) == target then return mapping end
  end
end

local function register_key(state, key, load, declaration)
  local lhs, rhs = key[1], key[2]
  local modes = key.mode or 'n'
  if type(modes) == 'string' then modes = { modes } end
  -- Expand combined modes so a replacement in one mode preserves the others.
  local aliases = {
    v = { 'x', 's' },
    [''] = { 'n', 'x', 's', 'o' },
    ['!'] = { 'i', 'c' },
  }
  local expanded = {}
  for _, mode in ipairs(modes) do
    for _, actual in ipairs(aliases[mode] or { mode }) do
      expanded[actual] = true
    end
  end
  state.keybindings = state.keybindings or {}
  local normalized = api.nvim_replace_termcodes(lhs, true, true, true)
  for mode in pairs(expanded) do
    local id = mode .. '\0' .. normalized
    local previous = state.keybindings[id]
    if
      previous
      and state.declarations[previous] > state.declarations[declaration]
    then
      expanded[mode] = nil
    else
      state.keybindings[id] = declaration
    end
  end
  local opts = {
    desc = key.desc,
    remap = key.noremap == false,
    silent = key.silent ~= false,
  }
  -- A keys callback can load synchronously before returning its declarations.
  if state.status == 'loaded' then
    for mode in pairs(expanded) do
      if rhs ~= nil and not global_keymap(mode, lhs) then
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end
    return
  end
  local replay = api.nvim_replace_termcodes(lhs, true, false, true)
  local function trigger()
    load()
    api.nvim_feedkeys(replay, 'mi', false)
  end
  for mode in pairs(expanded) do
    local owned = false
    vim.keymap.set(mode, lhs, trigger, opts)
    state.cleanups[#state.cleanups + 1] = function()
      local mapping = global_keymap(mode, lhs)
      owned = mapping ~= nil and mapping.callback == trigger
      if owned then vim.keymap.del(mode, lhs) end
    end
    state.keymaps[#state.keymaps + 1] = function()
      if owned and rhs ~= nil and not global_keymap(mode, lhs) then
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end
  end
end

---@param spec PackSpec
local function register_triggers(spec, state)
  local function load(event)
    if
      type(event) ~= 'table'
      or not event.event
      or ar.pack.loaded[spec.src]
    then
      load_spec(spec)
      return
    end
    local existing_groups = event_groups(event.event)
    load_spec(spec)
    if ar.pack.loaded[spec.src] then replay_event(event, existing_groups) end
  end
  if spec.cmd and not ar.pack.loaded[spec.src] then
    state.cleanups[#state.cleanups + 1] = ar.pack.cmd(spec.cmd, load)
  end
  local function register_event(event, opts)
    local id = api.nvim_create_autocmd(event, opts)
    state.cleanups[#state.cleanups + 1] = function()
      pcall(api.nvim_del_autocmd, id)
    end
  end
  if spec.event and not ar.pack.loaded[spec.src] then
    local events = type(spec.event) == 'string' and { spec.event } or spec.event
    for _, event in ipairs(events) do
      if event == 'VeryLazy' then
        state.cleanups[#state.cleanups + 1] = on_very_lazy(load)
      else
        register_event(event, {
          once = true,
          callback = load,
        })
      end
    end
  end
  if spec.ft and not ar.pack.loaded[spec.src] then
    register_event('FileType', {
      pattern = spec.ft,
      once = true,
      callback = load,
    })
  end
  if spec.keys then
    local keys = spec.keys
    if type(keys) == 'function' then keys = keys(load) end
    if state.status == 'failed' then load() end
    if type(keys) ~= 'table' then return end
    for _, key in ipairs(keys) do
      register_key(state, key, load, spec)
    end
  end
end

local function collect_spec(spec, dependency, order, seen)
  if ar.pack.loaded[spec.src] then return end
  local state = pack_states[spec.src]
  if state and (state.status == 'loading' or state.status == 'failed') then
    load_spec(spec)
    return
  end
  if not check_condition(spec) then return end
  if not state then
    state = {
      status = 'registered',
      spec = { src = spec.src, dependencies = {} },
      declarations = {},
      priorities = {},
      dependencies = {},
      pending = {},
      default_lazy = true,
    }
    pack_states[spec.src] = state
  end
  if not seen[state] then
    order[#order + 1], seen[state] = state, true
  end
  if not dependency and not state.standalone then
    state.standalone, state.default_lazy = true, ar.pack.defaults.lazy
  end
  local priority = dependency and 1 or 2
  local previous = state.declarations[spec] or 0
  if previous >= priority or state.preparing then return end
  state.declarations[spec] = priority
  if previous == 0 then state.pending[#state.pending + 1] = spec end
  for field, value in pairs(spec) do
    if
      field ~= 'dependencies' and priority >= (state.priorities[field] or 0)
    then
      state.spec[field], state.priorities[field] = value, priority
    end
  end
  for _, dep in ipairs(spec.dependencies or {}) do
    if check_condition(dep) then
      if not state.dependencies[dep.src] then
        state.dependencies[dep.src] = true
        state.spec.dependencies[#state.spec.dependencies + 1] = dep
      end
      collect_spec(dep, true, order, seen)
    end
  end
end

local function prepare_spec(state)
  local spec = state.spec
  if ar.pack.loaded[spec.src] or state.preparing then return end
  if state.status == 'loading' or state.status == 'failed' then
    load_spec(spec)
    return
  end
  state.preparing = true
  state.cleanups, state.keymaps = state.cleanups or {}, state.keymaps or {}
  local ok, err = xpcall(function()
    for _, dep in ipairs(spec.dependencies) do
      if check_condition(dep) and pack_states[dep.src] then
        prepare_spec(pack_states[dep.src])
      end
    end
    if spec.init and not state.initialized then
      state.initialized = true
      spec.init()
    end
    local changed_build = state.build ~= spec.build
      or state.build_name ~= spec.name
    if
      state.build_cleanup and (changed_build or spec.dev or not spec.build)
    then
      state.build_cleanup()
      state.build_cleanup = nil
    end
    if spec.build and not spec.dev and not state.build_cleanup then
      state.build_cleanup = require('ar.pack_build').register(spec)
      state.build, state.build_name = spec.build, spec.name
    end
    local pending = state.pending
    state.pending = {}
    for _, declaration in ipairs(pending) do
      register_triggers(declaration, state)
    end
  end, debug.traceback)
  state.preparing = nil
  if not ok then
    for _, cleanup in ipairs(state.cleanups or {}) do
      pcall(cleanup)
    end
    state.cleanups, state.keymaps = nil, nil
    state.status, state.error = 'failed', err
    error(err, 0)
  end
end

--- Load a registered source URL or an unambiguous native package name.
---@param name string
---@return boolean loaded True only when this call loads the plugin.
function ar.pack.load(name)
  local state = pack_states[name]
  if not state then
    for src, candidate in pairs(pack_states) do
      local package_name = candidate.spec.name
        or src:gsub('/+$', ''):match('([^/]+)$'):gsub('%.git$', '')
      if package_name == name then
        assert(
          not state,
          'Ambiguous plugin name: ' .. name .. '; use its source URL'
        )
        state = candidate
      end
    end
  end
  assert(state, 'Unknown registered plugin: ' .. name)
  if ar.pack.loaded[state.spec.src] then return false end
  prepare_spec(state)
  load_spec(state.spec)
  return ar.pack.loaded[state.spec.src] == true
end

--- Register one plugin spec or a list of specs with vim.pack. The whole batch
--- and its dependency specs register before eager loading; an empty list does
--- nothing. Supports command, filetype, key, or event loading. Standalone specs
--- default to ar.pack.defaults.lazy; dependency-only specs default to lazy.
--- Set lazy = false to load after registration, even with triggers. With
--- lazy = true, loading requires a trigger or use as a dependency; no triggers
--- means no automatic loading. ar.pack.load(src_or_name) explicitly loads a
--- registered source URL or unambiguous package name, returning false if loaded.
--- Any supplied trigger can load it. Filetype triggers handle future FileType events.
--- Owned command, key, event, and filetype triggers are removed before loading
--- dependencies or setup, including when loading later fails. Successful loading
--- installs declared key actions where setup has not supplied a mapping. Later
--- command and key replacements are preserved. Pending VeryLazy work is cancelled.
--- Triggers created manually inside keys(load) remain the caller's responsibility.
--- load = false uses native :packadd! behavior: add runtime paths without sourcing
--- plugin scripts immediately. setup still runs; lazy controls registration timing.
---
--- event accepts an autocmd event name or list, such as 'InsertEnter' or
--- { 'BufReadPost', 'BufNewFile' }. Only future events trigger loading; the event
--- is replayed after successful loading for augroups with no prior handlers for
--- that event, including handlers added by dependencies during loading. Existing
--- groups for that event and ungrouped handlers are skipped to avoid rerunning
--- unrelated handlers. Replay preserves the triggering buffer, match and data,
--- uses native pattern matching and once behavior, and skips deleted buffers.
--- Command, key and VeryLazy loading do not synthesize past events.
--- 'VeryLazy' schedules loading after VimEnter, or on the next scheduled callback
--- if startup has finished. It can appear in event lists and does not emit a
--- global User VeryLazy event. Scheduled loading is skipped while exiting.
---
--- keys entries contain a lhs and a string or function action, with optional
--- mode and desc fields. The default mode is normal. On first use, the plugin
--- loads and the pressed key is replayed through the resulting mapping.
--- Counts and registers on the first press are not explicitly preserved.
---
--- init runs once per source during registration, before its triggers or loading.
--- Dependency initialization precedes parent initialization. Use init for globals
--- or other configuration that must precede plugin loading. cond = false skips
--- registration, initialization, build hooks, and that declaration's dependencies.
---
--- Declarations share a source registry. Standalone fields take precedence over
--- inline dependency fields; later declarations at the same level win. Dependency
--- lists combine in declaration order and triggers accumulate. Conflicting key
--- actions prefer standalone declarations, then the latest declaration. Reusing
--- a spec table does not repeat its registration callbacks. Already loaded
--- sources ignore later declarations and are never reconfigured automatically.
---
--- Dependencies load before the plugin, and setup runs after vim.pack.add().
--- Each source URL loads and configures once through this wrapper, so use the
--- same full URL in standalone entries and dependencies. Recursive loads are
--- rejected; cycles report the active source URL path. A failed
--- load retains its error and is not retried in the same session, since plugin
--- scripts or setup may have already run partially. Only successful setup marks
--- the source as loaded in ar.pack.loaded. Installation does not
--- prompt for confirmation. Set cond = false to skip loading and trigger creation.
--- cond also accepts a function returning a boolean. Its result is cached on the
--- declaration at registration, including dependency declarations.
---
--- dev = true loads ar.pack.dev.path/<repository-name> through a temporary native
--- package symlink. The default dev directory is ~/projects. A trailing .git is
--- removed from the repository name. Missing checkouts raise an error; there is
--- no remote fallback. Dev plugins skip PackChanged build hooks and keep src as
--- their loaded-cache key. Dependencies can also set dev = true.
--- name and version are forwarded to vim.pack for remote plugins and dependencies.
--- Build hooks match the explicit name when supplied.
---
--- build accepts a shell command string, an argument list, or a Lua callback.
--- Commands run in the plugin directory through vim.system, with at most two
--- command builds running concurrently and one per source. build_wait defaults
--- to true so builds finish before setup; false permits background command
--- builds. build_timeout sets the command timeout in milliseconds, default 300000.
--- Failures capture stdout, stderr, and exit code; waited failures prevent setup.
--- require('ar.pack_build').jobs[src] exposes the latest build result.
---
--- Successful command builds are cached by revision and command under the state
--- directory's ar-pack/builds folder. Commands also run on first load if no build
--- record exists. Fresh installations always rebuild; failed attempts invalidate
--- earlier records. Lua callbacks retain their original PackChanged arguments,
--- run synchronously on each install or update, and manage any work they schedule
--- themselves. Callback results are not cached across revisions or sessions.
--- Dependency entries support the full spec, including init, build and triggers.
---
--- e.g.
--- ```lua
---   ar.pack.add({
---     src = 'https://github.com/folke/todo-comments.nvim',
---     cond = ar.get_plugin_cond('todo-comments.nvim'),
---     cmd = { 'TodoQuickFix' },
---     keys = {
---       { '<leader>tq', '<Cmd>TodoQuickFix<CR>', desc = 'Todo quickfix' },
---     },
---     dependencies = {
---       { src = 'https://github.com/nvim-lua/plenary.nvim' },
---     },
---     setup = function()
---       require('todo-comments').setup({ signs = false })
---     end,
---   })
--- ```
---
--- A list uses the same spec format for each entry:
--- ```lua
---   ar.pack.add({
---     { src = 'https://github.com/stevearc/oil.nvim' },
---     { src = 'https://github.com/folke/todo-comments.nvim' },
---   })
--- ```
---@param specs PackSpec|PackSpec[]
function ar.pack.add(specs)
  local order, seen = {}, {}
  if specs.src then
    collect_spec(specs, false, order, seen)
  else
    for _, spec in ipairs(specs) do
      collect_spec(spec, false, order, seen)
    end
  end
  for _, state in ipairs(order) do
    prepare_spec(state)
  end
  for _, state in ipairs(order) do
    local lazy = state.spec.lazy
    if lazy == nil then lazy = state.default_lazy end
    if not lazy and not state.preparing then load_spec(state.spec) end
  end
end

--------------------------------------------------------------------------------
--  FILETYPE HELPERS
--------------------------------------------------------------------------------

---@class FiletypeSettings
---@field g table<string, any>
---@field bo vim.bo
---@field wo vim.wo
---@field opt vim.Option
---@field plugins {[string]: fun(module: table)}

---@param args {[1]: string, [2]: string, [3]: string, [4]?: vim.keymap.set.Opts}[]
---@param buf integer
local function apply_ft_mappings(args, buf)
  vim.iter(args):each(function(m)
    local opts = vim.tbl_extend('force', { buffer = buf }, m[4] or {})
    map(m[1], m[2], m[3], opts)
  end)
end

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
---@param configs table<string, fun(module: table)>
function ar.ftplugin_conf(configs)
  if type(configs) ~= 'table' then return end
  for name, callback in pairs(configs) do
    local ok, plugin = ar.pcall(require, name)
    if ok then callback(plugin) end
  end
end

--- This function is an alternative API to using ftplugin files. It allows defining
--- filetype settings in a single place, then creating FileType autocommands from this definition
---
--- e.g.
--- ```lua
---   ar.filetype_settings({
---     lua = {
---      opt = {foldmethod = 'expr' },
---      bo = { shiftwidth = 2 }
---     },
---    [{'c', 'cpp'}] = {
---      bo = { shiftwidth = 2 }
---    }
---   })
--- ```
--- One future idea is to generate the ftplugin files from this function, so the settings are still
--- centralized but the curation of these files is automated. Although I'm not sure this actually
--- has value over autocommands, unless ftplugin files specifically have that value
---@param map {[string|string[]]: FiletypeSettings | {[integer]: fun(args: AutocmdArgs) | string}}
function ar.filetype_settings(map)
  local commands = {}
  for ft, settings in pairs(map) do
    local name = type(ft) == 'table' and table.concat(ft, ',') or ft
    commands[#commands + 1] = {
      pattern = ft,
      event = 'FileType',
      desc = ('ft settings for %s'):format(name),
      command = function(args)
        vim.iter(settings):each(function(key, value)
          if key == 'opt' then key = 'opt_local' end
          if key == 'mappings' then
            return apply_ft_mappings(value, args.buf)
          end
          if key == 'plugins' then return ar.ftplugin_conf(value) end
          if type(key) == 'function' then ar.pcall(key, args) end
          if value ~= nil then
            vim
              .iter(value)
              :each(function(option, setting) vim[key][option] = setting end)
          end
        end)
      end,
    }
  end
  ar.augroup('filetype-settings', unpack(commands))
end

---@param str string
---@param max_len integer
---@return string
function ar.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len
      and str:sub(1, max_len) .. ar.ui.icons.misc.ellipsis
    or str
end

---------------------------------------------------------------------------------
-- Open media files
---------------------------------------------------------------------------------

---@return string[]
function ar.get_media()
  local media = ar.media
  local extensions = {}
  for _, group in ipairs({ media.audio, media.doc, media.image, media.video }) do
    vim.list_extend(extensions, group)
  end
  return extensions
end

--- search current word or go to file
--- replicate netrw functionality
---@param path string
---@param notify? boolean
function ar.open(path, notify)
  notify = notify or false
  if notify then vim.notify(fmt('Opening %s', path)) end
  local _, err = vim.ui.open(path)
  if err ~= nil then
    local open_command = vim.g.os == 'Darwin' and 'open' or 'xdg-open'
    vim.system({ open_command, path }, { detach = true })
  end
end

--- Open the current file in the file manager
---@param file_path string
function ar.open_in_file_manager(file_path)
  if file_path == '' then
    print('File path is empty!')
    return
  end
  local exe = ar.config.apps.explorer
  if exe and fn.executable(exe) then
    vim.system({ exe, file_path }, { detach = true })
  end
end

--- open / play media file
---@param path string
---@param notify? boolean
function ar.open_media(path, notify)
  local file_extension = path:match('^.+%.(.+)$')
  local apps, media = ar.config.apps, ar.media
  local is_audio = vim.list_contains(media.audio, file_extension)
  local is_video = vim.list_contains(media.video, file_extension)
  local is_doc = vim.list_contains(media.doc, file_extension)
  local is_img = vim.list_contains(media.image, file_extension)
  local exe = apps.explorer
  if is_audio or is_video then exe = apps.video end
  if is_doc then exe = apps.pdf end
  if is_img then exe = apps.image end
  if exe and fn.executable(exe) then
    vim.system({ exe, path }, { detach = true, stdout = false, stderr = false })
    return
  end

  ar.open(path, notify)
end

---------------------------------------------------------------------------------
-- Open with window picker
---------------------------------------------------------------------------------

---@param callback fun(picked_window_id: number)
---@param set_current_win boolean
---@param command? 'split' | 'vsplit'
local function use_window_picker(callback, set_current_win, command)
  local picked_window_id = api.nvim_get_current_win()
  if ar.has('nvim-window-picker') then
    picked_window_id = require('window-picker').pick_window({
      include_current_win = true,
    })
  end
  if picked_window_id then
    if set_current_win then api.nvim_set_current_win(picked_window_id) end
    local ignored_filetypes = { 'neo-tree', 'quickfix' }
    local visible_bufs = {}
    vim.iter(api.nvim_list_wins()):each(function(w)
      local buf = api.nvim_win_get_buf(w)
      if not vim.tbl_contains(ignored_filetypes, vim.bo[buf].ft) then
        table.insert(visible_bufs, buf)
      end
    end)
    if #visible_bufs > 1 then
      if command then vim.cmd(command) end
    end
    callback(picked_window_id)
  end
end

--- open file in window picker if available
---@param callback fun(picked_window_id: number)
---@param set_current_win? boolean
function ar.open_with_window_picker(callback, set_current_win)
  if set_current_win == nil then set_current_win = true end
  use_window_picker(callback, set_current_win)
end

---@param callback fun(picked_window_id: number)
---@param set_current_win? boolean
function ar.split_with_window_picker(callback, set_current_win)
  if set_current_win == nil then set_current_win = true end
  use_window_picker(callback, set_current_win, 'split')
end

---@param callback fun(picked_window_id: number)
---@param set_current_win? boolean
function ar.vsplit_with_window_picker(callback, set_current_win)
  if set_current_win == nil then set_current_win = true end
  use_window_picker(callback, set_current_win, 'vsplit')
end

--- open in centered popup
---@param bufnr integer
---@param readonly? boolean
---@param opts? vim.api.keyset.win_config
---@return integer winid
function ar.open_buf_centered_popup(bufnr, readonly, opts)
  opts = opts or {}
  local o = vim.o
  local width = opts.width or math.ceil(o.columns * 0.8)
  local height = opts.height or math.ceil(o.lines * 0.8)
  local col = math.ceil((o.columns - width) / 2)
  local row = math.ceil((o.lines - height) / 2)

  local win_opts = vim.tbl_extend('force', {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    border = vim.o.winborder,
    style = 'minimal',
  }, opts)
  local winid = api.nvim_open_win(bufnr, true, win_opts)
  map('n', 'q', ar.smart_close, { buffer = bufnr, nowait = true })

  if readonly then
    api.nvim_set_option_value('readonly', true, { buf = bufnr })
    api.nvim_set_option_value('bufhidden', 'delete', { buf = bufnr })
    api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
    api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  end
  return winid
end

-- https://github.com/Wansmer/nvim-config/blob/main/lua/utils.lua?plain=1#L283
---Show image in float window
---@param path string Path to image
---@param win_opts? table Options for float window
---@param image_opts? table Options for image render (see image.nvim ImageGeometry)
function ar.show_image(path, win_opts, image_opts)
  local ok, img_api = pcall(require, 'image')
  if not ok then
    vim.notify('image.nvim is required')
    return
  end

  local buf = api.nvim_create_buf(false, true)
  local ok_image, image = pcall(img_api.from_file, path, { buffer = buf })
  if not (ok_image and image) then return end

  local term = require('image.utils.term')
  local term_size = term.get_size()
  local image_rows = math.floor(image.image_height / term_size.cell_height)
  local image_columns = math.floor(image.image_width / term_size.cell_width)

  win_opts = vim.tbl_deep_extend('force', {
    relative = 'cursor',
    col = 0,
    row = 0,
    width = image_columns,
    height = image_rows + 1,
    style = 'minimal',
  }, win_opts or {})

  local win = api.nvim_open_win(buf, false, win_opts)

  image.window = win
  -- Needed to correct render if window is moved
  vim.schedule(function() image:render(image_opts or {}) end)

  local group = api.nvim_create_augroup('__image__', { clear = true })
  local cursor = api.nvim_win_get_cursor(0)

  api.nvim_create_autocmd('CursorMoved', {
    group = group,
    callback = function()
      local c = api.nvim_win_get_cursor(0)
      if c[1] ~= cursor[1] then
        image:clear()
        api.nvim_win_close(win, true)
        api.nvim_buf_delete(buf, { force = true })
        api.nvim_del_augroup_by_name('__image__')
      end
    end,
  })
end

--- search current word in website. see usage below
---@param path string
---@param url string
function ar.web_search(path, url)
  local query = '"' .. fn.substitute(path, '["\n]', ' ', 'g') .. '"'
  ar.open(fmt('%s%s', url, query), true)
end

-- move file to trash
---@param path string
function ar.trash_file(path, notify)
  if fn.executable('trash') == 0 then
    vim.notify('Trash utility not installed', L.ERROR)
    return
  end
  notify = notify or false
  local success, _ = pcall(
    function() vim.system({ 'gio', 'trash', path }):wait() end
  )
  if not notify then return end
  if success then
    vim.notify(fmt('Moved %s to trash', path), L.INFO)
  else
    vim.notify('Failed to delete file', L.ERROR)
  end
end

---------------------------------------------------------------------------------

---Determine if a value of any type is empty
---@param item any
---@return boolean
function ar.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

--------------------------------------------------------------------------------
-- API Wrappers
--------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

local autocmd_keys =
  { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
--- Validate the keys passed to ar.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = {}
  for key in pairs(command) do
    if not vim.tbl_contains(autocmd_keys, key) then
      table.insert(incorrect, key)
    end
  end

  if #incorrect > 0 then
    vim.schedule(function()
      local msg = ('Incorrect keys: %s'):format(table.concat(incorrect, ', '))
      vim.notify(msg, 'error', { title = ('Autocmd: %s'):format(name) })
    end)
  end
end

---@class AutocmdArgs
---@field id number
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string?
---@field event  (string | string[])? list of autocommand events
---@field pattern (string | string[])? list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean?
---@field once    boolean?
---@field buffer  number?

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
function ar.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(
    #commands > 0,
    fmt('You must specify at least one autocommand for %s', name)
  )
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      ---@diagnostic disable-next-line: assign-type-mismatch
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts? table
function ar.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return string
function ar.replace_termcodes(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

---@generic T
---Given a table return a new table which if the key is not found will search
---all the table's keys for a match using `string.match`
---@param map T
---@return T
function ar.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end

--- Insert values from one list into another
---@param list table
---@param ... table
function ar.list_insert(list, ...)
  if type(list) ~= 'table' then return end
  local values = {}
  for _, items in ipairs({ ... }) do
    vim.list_extend(values, items)
  end
  vim.list_extend(list, values)
end

--- source: https://github.com/tjdevries/lazy-require.nvim

--- Require on index.
---
--- Will only require the module after the first index of a module.
--- Only works for modules that export a table.
function ar.reqidx(require_path)
  return setmetatable({}, {
    __index = function(_, key) return require(require_path)[key] end,
    __newindex = function(_, key, value) require(require_path)[key] = value end,
  })
end

--- Find the first entry for which the predicate returns true.
-- @param t The table
-- @param predicate The function called for each entry of t
-- @return The entry for which the predicate returned True or nil
function ar.find_first(t, predicate)
  for _, entry in pairs(t) do
    if predicate(entry) then return entry end
  end
  return nil
end

---@param require_path string
---@return table<string, fun(...): any>
function ar.reqcall(require_path)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...) return require(require_path)[k](...) end
    end,
  })
end

---@param bool boolean
---@return string
function ar.bool2str(bool) return bool and 'on' or 'off' end

function ar.change_filetype()
  vim.ui.input({ prompt = 'Change filetype to: ' }, function(new_ft)
    if new_ft ~= nil then vim.bo.filetype = new_ft end
  end)
end
