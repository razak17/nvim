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

---@param callback function
---@param opts { forward: boolean }
---@return function
function ar.demicolon_jump(callback, opts)
  if not ar.is_available('demicolon.nvim') then
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
  ar.mergeTables(ar, table)
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
    if ar.debug.enable then
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

--- Get plugins spec
function ar.plugins_spec()
  local plugins_path = fn.stdpath('config') .. '/lua/ar/plugins'
  local plugins_list = vim.fs.find(function(name, _)
    local filename = name:match('(.+)%.lua$')
    return name:match('.*.lua$') and not ar.module_disabled(filename)
  end, { path = plugins_path, limit = math.huge, type = 'file' })
  return vim.iter(plugins_list):fold({}, function(acc, path)
    local _, pos = path:find(plugins_path)
    acc[#acc + 1] = { import = 'ar.plugins.' .. path:sub(pos + 2, #path - 4) }
    return acc
  end)
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
  return ar.find_string(ar.plugins.disabled, plugin)
end

-- Check if a module is disabled
---@param module string The module to search for.
---@return boolean disabled # Whether the module is disabled.
function ar.module_disabled(module)
  return ar.find_string(ar.plugins.modules.disabled, module)
end

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  if not lazy_config_avail then return false end
  return lazy_config.plugins[plugin] ~= nil
end

---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function ar.plugin_available(plugin)
  if not ar.is_available(plugin) then
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

-- Check if a lsp is disabled
---@param lsp string The lsp to search for.
---@return boolean disabled # Whether the lsp is disabled.
function ar.lsp_disabled(lsp)
  return ar.find_string(ar.lsp.disabled.servers, lsp)
end

---Get whether using nightly version of neovim
local LATEST_NIGHTLY_MINOR = 10
function ar.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

function ar.reload_all()
  cmd('checktime')
  cmd('Gitsigns refresh')
end

--- Run a command
---@param command string
---@param params table
---@param cb? function
function ar.run_command(command, params, cb)
  local Job = require('plenary.job')
  local error_msg = nil
  Job
    :new({
      command = command,
      args = params,
      on_stderr = function(_, data, _)
        if error_msg == nil then error_msg = data end
      end,
      on_exit = function(_, code, _)
        vim.schedule_wrap(function()
          if code == 0 then
            vim.notify(command .. ' executed successfully', vim.log.levels.INFO)
            if cb then cb() end
          else
            local info = { command .. ' failed!' }
            if error_msg ~= nil then
              table.insert(info, error_msg)
              print(error_msg)
            end
            vim.notify(info, vim.log.levels.ERROR)
          end
        end)()
      end,
    })
    :start()
  vim.notify(command .. ' launched...', vim.log.levels.INFO)
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
---@alias MenuOptions 'ai' | 'command_palette' | 'git' | 'lsp' | 'toggle'

--- Add options to menu
---@param name MenuOptions
---@param options table
function ar.add_to_menu(name, options)
  ar.menu[name].options = ar.menu[name].options or {}
  ar.menu[name].options =
    vim.tbl_extend('force', ar.menu[name].options, options)
end

function ar.escape_pattern(text) return text:gsub('([^%w])', '%%%1') end

--- copy some text to clipboard
---@param to_copy string
function ar.copy_to_clipboard(to_copy) fn.setreg('+', to_copy) end

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

-- Get project info for all (de)activated projects
function ar.get_projects()
  if not ar.is_available('project_nvim') then
    vim.notify('project.nvim is not installed')
    return
  end

  local projects_file = fn.stdpath('data') .. '/project_nvim/project_history'

  local projects = {}
  for line in io.lines(projects_file) do
    table.insert(projects, line)
  end
  return projects
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
  -- Given the table of options, populate an array with option display names
  local option_names = {}
  if ar.frecency.enable then
    local top_items = frecency.top_items(
      function(_, data) return data.prompt == prompt end
    )
    option_names = vim
      .iter(top_items)
      :map(function(item) return item.name end)
      :totable()
  else
    option_names = vim
      .iter(options_table)
      :map(function(i, _) return i end)
      :totable()
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
        if ar.frecency.enable then
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
          vim
            .iter(value)
            :each(function(option, setting) vim[key][option] = setting end)
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
  local exe = ar.apps.explorer
  if exe and fn.executable(exe) then
    vim.system({ exe, file_path }, { detach = true })
  end
end

--- open / play media file
---@param path string
---@param notify? boolean
function ar.open_media(path, notify)
  local file_extension = path:match('^.+%.(.+)$')
  local apps, media = ar.apps, ar.media
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

--- open file in window picker
---@param buf? integer
function ar.open_with_window_picker(buf)
  if not ar.is_available('nvim-window-picker') then
    vim.notify('window-picker is not installed', vim.log.levels.ERROR)
    return
  end
  local picked_window_id = require('window-picker').pick_window()
  if picked_window_id then
    api.nvim_set_current_win(picked_window_id)
    if buf then api.nvim_set_current_buf(buf) end
  end
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

--- Copy `text` to system clipboard
---@param text string
function ar.copy(text)
  fn.setreg('+', text)
  vim.notify('Copied to clipboard', vim.log.levels.INFO)
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
  local success, _ = pcall(function() fn.system({ 'gio', 'trash', path }) end)
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

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function ar.has(feature) return fn.has(feature) > 0 end

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
