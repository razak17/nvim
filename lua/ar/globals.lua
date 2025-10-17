if not ar then return end

local fn, api, cmd, uv, fmt = vim.fn, vim.api, vim.cmd, vim.uv, string.format
local L = vim.log.levels

---Join path segments that were passed as input
---@return string
function join_paths(...)
  local path_sep = uv.os_uname().version:match('Windows') and '\\' or '/'
  local result = table.concat({ ... }, path_sep)
  return result
end

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
  if not ar.has('demicolon.nvim') then
    return function() return callback(opts) end
  end
  return function() require('demicolon.jump').repeatably_do(callback, opts) end
end

function ar.remove_duplicates(table)
  local seen = {}
  return vim
    .iter(table)
    :filter(function(s)
      if not seen[s] then
        seen[s] = true
        return true
      end
      return false
    end)
    :totable()
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
function ar.project_config(file)
  if not file then return end
  local json = file:read('*a')
  local status, table = pcall(fn.json_decode, json)
  io.close(file)
  if not status then
    cmd("echohl ErrorMsg | echo 'Error: Invalid json' | echohl None")
    vim.notify('Invalid json found in .rvim.json', 'error')
    return
  end
  ar.mergeTables(ar_config, table)
end

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param minheight number
---@param maxheight number
function ar.adjust_split_height(minheight, maxheight)
  local line = fn.line('$') -- Assuming fn.line('$') returns an integer or nil

  if not line then line = 0 end

  api.nvim_win_set_height(0, math.max(math.min(line, maxheight), minheight))
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
    if ar_config.debug.enable then
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
  return vim.tbl_contains(ar_config.plugins.disabled, plugin)
end

-- Get a plugin's enable condition
---@param plugin string The plugin to search for.
---@param cond boolean # Other conditions to check.
---@return boolean disabled # Whether the plugin is disabled.
function ar.get_plugin_cond(plugin, cond)
  local disabled = ar.plugin_disabled(plugin)
  if disabled then return false end
  if cond == nil then cond = true end
  return cond
end

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.has(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  if not lazy_config_avail then return false end
  return lazy_config.plugins[plugin] ~= nil
end

---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.plugin_available(plugin)
  if not ar.has(plugin) then
    vim.notify(
      fmt('%s is not available', plugin),
      L.INFO,
      { title = 'Plugins' }
    )
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
      if ar_config.debug.enable then
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

  if ar_config.debug.enable then
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

function ar.ts_extra_enabled()
  return ar.treesitter.enable and ar.treesitter.extra.enable
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
  return vim.tbl_contains(ar_config.lsp.disabled.servers, lsp)
end

-- Check if a lsp is disabled in a directory
---@param dir string The directory to search for.
---@return boolean disabled # Whether the lsp is disabled.
function ar.dir_lsp_disabled(dir)
  return ar.dirs_match(ar_config.lsp.disabled.directories, fmt('%s', dir))
end

---@param lsp string The lsp to search for.
---@return boolean disabled # Whether the lsp is disabled.
function ar.lsp_override(lsp)
  return not ar.falsy(ar_config.lsp.override)
    and not vim.tbl_contains(ar_config.lsp.override, lsp)
end

---Get whether using nightly version of neovim
local LATEST_NIGHTLY_MINOR = 10
function ar.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

function ar.reload_all()
  cmd('checktime')
  cmd('Gitsigns refresh')
end

-- Ref: https://github.com/serranomorante/dotfiles/blob/main/nvim/dot-config/nvim/lua/serranomorante/utils.lua?plain=1#L186
---Simple setTimeout wrapper
---@param callback function
---@param timeout integer
---@param ms integer
function ar.set_timeout(callback, timeout, ms)
  local timer = vim.uv.new_timer()
  if timer == nil then return end
  timer:start(timeout, ms, function()
    timer:stop()
    timer:close()
    if callback then callback() end
  end)
  return timer
end

--- Run a command
---@param command string
---@param params table
---@param exit_cb? function
---@param start_cb? function
function ar.run_command(command, params, exit_cb, start_cb)
  local Job = require('plenary.job')
  local error_msg = nil
  Job:new({
    command = command,
    args = params,
    on_start = function()
      if start_cb then start_cb() end
    end,
    on_stderr = function(_, data, _)
      if error_msg == nil then error_msg = data end
    end,
    on_exit = function(job, code, _)
      vim.schedule_wrap(function()
        if code == 0 then
          if ar_config.debug.enable then
            vim.notify(command .. ' executed successfully', vim.log.levels.INFO)
          end
        else
          local info = { command .. ' failed!' }
          if error_msg ~= nil then
            table.insert(info, error_msg)
            print(error_msg)
          end
          if ar_config.debug.enable then
            vim.notify(info, vim.log.levels.ERROR)
          end
        end
        if exit_cb then exit_cb(job) end
      end)()
    end,
  }):start()
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
function ar.add_to_select_menu(name, options)
  ar.select_menu[name].options = ar.select_menu[name].options or {}
  ar.select_menu[name].options =
    vim.tbl_extend('force', ar.select_menu[name].options, options)
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
  ar.pcall('theme failed to load because', cmd.colorscheme, name)
end

-- Check if root directory is a git repo
---@return boolean
function ar.is_git_repo()
  return not ar.falsy(fn.isdirectory(fmt('%s/.git', fn.expand('%:p:h'))))
    or not ar.falsy(vim.b.gitsigns_head)
    or not ar.falsy(vim.b.gitsigns_status_dict)
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
  local option_names = vim
    .iter(options_table)
    :map(function(i, _) return i end)
    :totable()
  if ar_config.frecency.enable then
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
        if ar_config.frecency.enable then
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
--  FILETYPE HELPERS
--------------------------------------------------------------------------------

---@class FiletypeSettings
---@field g table<string, any>
---@field bo vim.bo
---@field wo vim.wo
---@field opt vim.Option
---@field plugins {[string]: fun(module: table)}

---@param args {[1]: string, [2]: string, [3]: string, [string]: boolean | integer}[]
---@param buf integer
local function apply_ft_mappings(args, buf)
  vim.iter(args):each(function(m)
    -- assert(#m == 3, 'map args must be a table with at least 3 items')
    local opts = vim.iter(m):fold({ buffer = buf }, function(acc, key, item)
      if type(key) == 'string' then acc[key] = item end
      return acc
    end)
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
  local commands = vim.iter(map):map(function(ft, settings)
    local name = type(ft) == 'table' and table.concat(ft, ',') or ft
    return {
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
  end)
  ar.augroup('filetype-settings', unpack(commands:totable()))
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

function ar.get_media()
  local media = ar.media
  return vim
    .iter({ media.audio, media.doc, media.image, media.video })
    :flatten()
    :totable()
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
  local exe = ar_config.apps.explorer
  if exe and fn.executable(exe) then
    vim.system({ exe, file_path }, { detach = true })
  end
end

--- open / play media file
---@param path string
---@param notify? boolean
function ar.open_media(path, notify)
  local file_extension = path:match('^.+%.(.+)$')
  local apps, media = ar_config.apps, ar.media
  local is_audio = vim.list_contains(media.audio, file_extension)
  local is_video = vim.list_contains(media.video, file_extension)
  local is_doc = vim.list_contains(media.doc, file_extension)
  local is_img = vim.list_contains(media.image, file_extension)
  local exe = apps.explorer
  if is_audio or is_video then exe = apps.video end
  if is_doc then exe = apps.pdf end
  if is_img then exe = apps.image end
  if exe and fn.executable(exe) then
    vim.system({ exe, path }, { detach = true })
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
function ar.open_buf_centered_popup(bufnr, readonly)
  local o = vim.o
  local width = math.ceil(o.columns * 0.8)
  local height = math.ceil(o.lines * 0.8)
  local col = math.ceil((o.columns - width) / 2)
  local row = math.ceil((o.lines - height) / 2)

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    border = 'single',
    style = 'minimal',
  }
  api.nvim_open_win(bufnr, true, opts)
  map('n', 'q', ar.smart_close, { buffer = bufnr, nowait = true })

  if readonly then
    api.nvim_set_option_value('readonly', true, { buf = bufnr })
    api.nvim_set_option_value('bufhidden', 'delete', { buf = bufnr })
    api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
    api.nvim_set_option_value('modifiable', false, { buf = bufnr })
  end
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

---Show image in float window using snacks.nvim
---@param path string Path to image
---@param win_opts? table Options for float window
function ar.snacks_show_image(path, win_opts)
  local ok, _ = pcall(require, 'snacks.image')
  if not ok then
    vim.notify('snacks.nvim is required')
    return
  end

  local current_buf = api.nvim_get_current_buf()
  win_opts = vim.tbl_deep_extend('keep', win_opts or {}, {
    width = 60,
    height = 17,
  })

  Snacks.image.doc.at_cursor(function(src)
    src = path
    local config = {
      border = 'single',
      backdrop = false,
      relative = 'editor',
      row = 1,
      float = true,
      show = false,
      enter = false,
      focusable = false,
    }
    local win = Snacks.win(config)
    win:show()
    local opts = Snacks.config.merge({}, Snacks.image.config.doc, {
      on_update_pre = function()
        win.opts.width = win_opts.width
        win.opts.height = win_opts.height
        win:show()
      end,
      inline = false,
    })
    local hover = {
      win = win,
      buf = current_buf,
      img = Snacks.image.placement.new(win.buf, src, opts),
    }

    vim.on_key(function()
      hover.win:close()
      hover.img:close()
    end, 0)
  end)
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
-- Quickfix and Location List
---------------------------------------------------------------------------------
ar.list = { qf = {}, loc = {} }

---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return vim
    .iter(fn.getwininfo())
    :find(function(win) return not ar.falsy(win[list_type]) end) ~= nil
end

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = api.nvim_get_current_win()
  callback(...)
  if win ~= api.nvim_get_current_win() then cmd.wincmd('p') end
end

function ar.list.qf.toggle()
  if is_list_open('quickfix') then
    cmd.cclose(silence)
  elseif #fn.getqflist() > 0 then
    preserve_window(cmd.copen, silence)
  end
end

function ar.list.loc.toggle()
  if is_list_open('loclist') then
    cmd.lclose(silence)
  elseif #fn.getloclist(0) > 0 then
    preserve_window(cmd.lopen, silence)
  end
end

-- @see: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/after/ftplugin/qf.lua#L13
-- using range-aware function
function ar.list.qf.delete(opts)
  local winid = api.nvim_get_current_win()
  local is_loclist = fn.win_gettype(winid) == 'loclist'
  local what = { items = 0, title = 0 }
  local list = is_loclist and fn.getloclist(0, what) or fn.getqflist(what)
  if #list.items > 0 then
    local row, col = unpack(api.nvim_win_get_cursor(0))
    for pos = opts.line2, opts.line1, -1 do
      table.remove(list.items, pos)
    end
    if is_loclist then
      fn.setloclist(0, {}, 'r', { items = list.items, title = list.title })
    else
      fn.setqflist({}, 'r', { items = list.items, title = list.title })
    end
    -- stylua: ignore
    api.nvim_win_set_cursor(0, { row > fn.line('$') and fn.line('$') or row, col })
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
  local incorrect = vim.iter(command):map(function(key, _)
    if not vim.tbl_contains(autocmd_keys, key) then return key end
  end)

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

function ar.list_insert(list, tbl)
  if not list or not tbl then return end
  if type(list) ~= 'table' or type(tbl) ~= 'table' then return end
  for _, v in pairs(tbl) do
    if not vim.tbl_contains(list, v) then table.insert(list, v) end
  end
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
