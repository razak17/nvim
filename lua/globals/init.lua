_GlobalCallbacks = _GlobalCallbacks or {}

_G.rvim = { _store = _GlobalCallbacks }

local api, fn = vim.api, vim.fn
local fmt = string.format
local os_name = vim.loop.os_uname().sysname

rvim._home = os.getenv("HOME")
rvim.__is_mac = os_name == "OSX"
rvim.__is_linux = os_name == "Linux"
rvim.__is_windows = os_name == "Windows"
rvim.__cache_dir = rvim._home .. "/.cache/rvim"
rvim.__vim_path = rvim._home .. "/.config/rvim"
rvim.__data_dir = rvim._home .. "/.local/share/rvim"
rvim._asdf = rvim._home .. "/.asdf/installs"
rvim._fnm = rvim._home .. "/.fnm/node-versions"
rvim._dap = rvim.__cache_dir .. "/venv/dap/"
rvim._golang = rvim._asdf .. "/golang/1.16.2/go/bin/go"
rvim._node = rvim._fnm .. "/v16.3.0/installation/bin/neovim-node-host"
rvim._python3 = rvim.__cache_dir .. "/venv/neovim/"
rvim.__plugins = rvim.__data_dir .. "/pack/"
rvim.__nvim_lsp = rvim.__cache_dir .. "/nvim_lsp"
rvim.__dap_install_dir = rvim.__cache_dir .. "/dap"
rvim.__dap_python = rvim.__dap_install_dir .. "/python_dbg/bin/python"
rvim.__dap_node = rvim.__dap_install_dir .. "/jsnode_dbg/vscode-node-debug2/out/src/nodeDebug.js"
rvim.__vsnip_dir = rvim.__vim_path .. "/snippets"
rvim.__session_dir = rvim.__data_dir .. "/session/dashboard"
rvim.__modules_dir = rvim.__vim_path .. "/lua/modules"
rvim.__sumneko_root_path = rvim.__nvim_lsp .. "/lua-language-server"
rvim.__elixirls_root_path = rvim.__nvim_lsp .. "/elixir-ls"

function rvim._create(f)
	table.insert(rvim._store, f)
	return #rvim._store
end

function rvim._execute(id, args)
	rvim._store[id](args)
end

function rvim.is_table(t)
	return type(t) == "table"
end

function rvim.is_string(t)
	return type(t) == "string"
end

function rvim.has_value(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

---Determine if a value of any type is empty
---@param item any
---@return boolean
function rvim.empty(item)
	if not item then
		return true
	end
	local item_type = type(item)
	if item_type == "string" then
		return item == ""
	elseif item_type == "table" then
		return vim.tbl_isempty(item)
	end
end

function rvim.command(args)
	local nargs = args.nargs or 0
	local name = args[1]
	local rhs = args[2]
	local types = (args.types and type(args.types) == "table") and table.concat(args.types, " ") or ""

	if type(rhs) == "function" then
		local fn_id = rvim._create(rhs)
		rhs = string.format("lua rvim._execute(%d%s)", fn_id, nargs > 0 and ", <f-args>" or "")
	end

	vim.cmd(string.format("command! -nargs=%s %s %s %s", nargs, types, name, rhs))
end

function rvim.augroup(name, commands)
	vim.cmd("augroup " .. name)
	vim.cmd("autocmd!")
	for _, c in ipairs(commands) do
		local command = c.command
		if type(command) == "function" then
			local fn_id = rvim._create(command)
			command = fmt("lua rvim._execute(%s)", fn_id)
		end
		vim.cmd(
			string.format(
				"autocmd %s %s %s %s",
				table.concat(c.events, ","),
				table.concat(c.targets or {}, ","),
				table.concat(c.modifiers or {}, " "),
				command
			)
		)
	end
	vim.cmd("augroup END")
end

---Check if a cmd is executable
---@param e string
---@return boolean
function rvim.executable(e)
	return fn.executable(e) > 0
end

function rvim.echomsg(msg, hl)
	hl = hl or "Title"
	local msg_type = type(msg)
	if msg_type ~= "string" or "table" then
		return
	end
	if msg_type == "string" then
		msg = { { msg, hl } }
	end
	vim.api.nvim_echo(msg, true, {})
end

-- https://stackoverflow.com/questions/1283388/lua-merge-tables
function rvim.deep_merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			rvim.deep_merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

---check if a mapping already exists
---@param lhs string
---@param mode string
---@return boolean
local function has_map(lhs, mode)
	mode = mode or "n"
	return vim.fn.maparg(lhs, mode) ~= ""
end

local function validate_opts(opts)
	if not opts then
		return true
	end

	if type(opts) ~= "table" then
		return false, "opts should be a table"
	end

	if opts.buffer and type(opts.buffer) ~= "number" then
		return false, "The buffer key should be a number"
	end

	return true
end

local function validate_mappings(lhs, rhs, opts)
	vim.validate({
		lhs = { lhs, "string" },
		rhs = {
			rhs,
			function(a)
				local arg_type = type(a)
				return arg_type == "string" or arg_type == "function"
			end,
			"right hand side",
		},
		opts = { opts, validate_opts, "mapping options are incorrect" },
	})
end

---create a mapping function factory
---@param mode string
---@param o table
---@return function
local function make_mapper(mode, o)
	-- copy the opts table rvim extends will mutate the opts table passed in otherwise
	local parent_opts = vim.deepcopy(o)
	---Create a mapping
	---@param lhs string
	---@param rhs string|function
	---@param opts table
	return function(lhs, rhs, opts)
		-- assert(lhs ~= mode,
		--        fmt("The lhs should not be the same rvim mode for %s", lhs))
		local _opts = opts and vim.deepcopy(opts) or {}

		validate_mappings(lhs, rhs, _opts)

		if _opts.check_existing and has_map(lhs) then
			return
		else
			-- don't pass this invalid key to set keymap
			_opts.check_existing = nil
		end

		-- add functions to a global table keyed by their index
		if type(rhs) == "function" then
			local fn_id = rvim._create(rhs)
			rhs = string.format("<cmd>lua rvim._execute(%s)<CR>", fn_id)
		end

		if _opts.buffer then
			-- Remove the buffer from the args sent to the key map function
			local bufnr = _opts.buffer
			_opts.buffer = nil
			_opts = vim.tbl_extend("force", _opts, parent_opts)
			api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, _opts)
		else
			api.nvim_set_keymap(mode, lhs, rhs, vim.tbl_extend("keep", _opts, parent_opts))
		end
	end
end

--- Check if a file or directory exists in this path
function rvim._exists(file)
	if file == "" or file == nil then
		return false
	end
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end

function rvim.check_lsp_client_active(name)
	local clients = vim.lsp.get_active_clients()
	for _, client in pairs(clients) do
		if client.name == name then
			return true
		end
	end
	return false
end

function rvim.invalidate(path, recursive)
	if recursive then
		for key, value in pairs(package.loaded) do
			if key ~= "_G" and value and vim.fn.match(key, path) ~= -1 then
				package.loaded[key] = nil
				require(key)
			end
		end
	else
		package.loaded[path] = nil
		require(path)
	end
end

local map_opts = { noremap = false, silent = true }
rvim.map = make_mapper("", map_opts)
rvim.nmap = make_mapper("n", map_opts)
rvim.xmap = make_mapper("x", map_opts)
rvim.imap = make_mapper("i", map_opts)
rvim.vmap = make_mapper("v", map_opts)
rvim.omap = make_mapper("o", map_opts)
rvim.tmap = make_mapper("t", map_opts)
rvim.smap = make_mapper("s", map_opts)
rvim.cmap = make_mapper("c", { noremap = false, silent = false })

local noremap_opts = { noremap = true, silent = true }
rvim.nnoremap = make_mapper("n", noremap_opts)
rvim.xnoremap = make_mapper("x", noremap_opts)
rvim.vnoremap = make_mapper("v", noremap_opts)
rvim.inoremap = make_mapper("i", noremap_opts)
rvim.onoremap = make_mapper("o", noremap_opts)
rvim.tnoremap = make_mapper("t", noremap_opts)
rvim.snoremap = make_mapper("s", noremap_opts)
rvim.cnoremap = make_mapper("c", { noremap = true, silent = false })

local function get_last_notification()
	for _, win in ipairs(api.nvim_list_wins()) do
		local buf = api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "vim-notify" and api.nvim_win_is_valid(win) then
			return api.nvim_win_get_config(win)
		end
	end
end

local notification_hl = setmetatable({
	[2] = { "FloatBorder:NvimNotificationError", "NormalFloat:NvimNotificationError" },
	[1] = { "FloatBorder:NvimNotificationInfo", "NormalFloat:NvimNotificationInfo" },
}, {
	__index = function(t, _)
		return t[1]
	end,
})

---Utility function to create a notification message
---@param lines string[] | string
---@param opts table
function rvim.notify(lines, opts)
	lines = type(lines) == "string" and { lines } or lines
	opts = opts or {}
	local highlights = { "NormalFloat:Normal" }
	local level = opts.log_level or 1
	local timeout = opts.timeout or 5000

	local width
	for i, line in ipairs(lines) do
		line = "  " .. line .. "  "
		lines[i] = line
		local length = #line
		if not width or width < length then
			width = length
		end
	end
	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	local height = #lines
	local prev = get_last_notification()
	local row = prev and prev.row[false] - prev.height - 2 or vim.o.lines - vim.o.cmdheight - 3
	local win = api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		col = vim.o.columns - 2,
		row = row,
		anchor = "SE",
		style = "minimal",
		focusable = false,
		border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
	})

	local level_hl = notification_hl[level]

	vim.list_extend(highlights, level_hl)
	vim.wo[win].winhighlight = table.concat(highlights, ",")

	vim.bo[buf].filetype = "vim-notify"
	vim.wo[win].wrap = true
	if timeout then
		vim.defer_fn(function()
			if api.nvim_win_is_valid(win) then
				api.nvim_win_close(win, true)
			end
		end, timeout)
	end
end
