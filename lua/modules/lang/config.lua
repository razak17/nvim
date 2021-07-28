local config = {}

-- Debug
function config.dap()
	require("debug.config")
end

function config.dap_ui()
	vim.cmd([[packadd nvim-dap]])
	require("dapui").setup({
		mappings = { expand = "<CR>", open = "o", remove = "d" },
		sidebar = {
			open_on_start = true,
			elements = { "scopes", "breakpoints", "stacks", "watches" },
			width = 50,
			position = "left",
		},
		tray = { open_on_start = false, elements = { "repl" }, height = 10, position = "bottom" },
		floating = { max_height = 0.4, max_width = 0.4 },
	})
end

function config.dap_install()
	vim.cmd([[packadd nvim-dap]])
	local dI = require("dap-install")
	dI.setup({ installation_path = rvim.__dap_install_dir })
end

-- Lsp
function config.nvim_lsp()
	require("modules.lang.lspconfig")
end

function config.nvim_lsp_settings()
	local lsp_settings_status_ok, lsp_settings = pcall(require, "nlspsettings")
	if lsp_settings_status_ok then
		lsp_settings.setup({
			config_home = rvim.__vim_path .. "/lspsettings",
		})
	end
end

function config.null_ls()
	local null_status_ok, null_ls = pcall(require, "null-ls")
	if null_status_ok then
		null_ls.config({})
		require("lspconfig")["null-ls"].setup({})
	end
end

function config.formatter()
	rvim.augroup("AutoFormat", { { events = { "BufWritePost" }, targets = { "*" }, command = ":silent FormatWrite" } })
end

function config.nvim_lint()
	rvim.augroup("AutoLint", {
		{
			events = { "BufWritePost" },
			targets = { "<buffer>" },
			command = ":silent lua require('lint').try_lint()",
		},
		{
			events = { "BufEnter" },
			targets = { "<buffer>" },
			command = ":silent lua require('lint').try_lint()",
		},
	})
end

function config.bqf()
	require("bqf").setup({
		preview = { border_chars = { "│", "│", "─", "─", "┌", "┐", "└", "┘", "█" } },
	})
end

function config.lightbulb()
	rvim.augroup("NvimLightbulb", {
		{
			events = { "CursorHold", "CursorHoldI" },
			targets = { "*" },
			command = function()
				require("nvim-lightbulb").update_lightbulb({
					sign = { enabled = false },
					virtual_text = { enabled = true },
				})
			end,
		},
	})
end

function config.lspsaga()
	vim.cmd([[packadd lspsaga.nvim]])
	local saga = require("lspsaga")
	saga.init_lsp_saga({
		use_saga_diagnostic_sign = false,
		code_action_icon = "💡",
		code_action_prompt = { enable = false, sign = false, virtual_text = false },
	})
	local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
	nnoremap("gd", ":Lspsaga lsp_finder<CR>")
	nnoremap("gsh", ":Lspsaga signature_help<CR>")
	nnoremap("gh", ":Lspsaga preview_definition<CR>")
	nnoremap("grr", ":Lspsaga rename<CR>")
	nnoremap("K", ":Lspsaga hover_doc<CR>")
	nnoremap("<Leader>va", ":Lspsaga code_action<CR>")
	vnoremap("<Leader>vA", ":Lspsaga range_code_action<CR>")
	nnoremap("<Leader>vdb", ":Lspsaga diagnostic_jump_prev<CR>")
	nnoremap("<Leader>vdn", ":Lspsaga diagnostic_jump_next<CR>")
	nnoremap("<Leader>vdl", ":Lspsaga show_line_diagnostics<CR>")
end

-- Treesitter
function config.nvim_treesitter()
	require("modules.lang.treesitter")
end

function config.autopairs()
	local status_ok, _ = pcall(require, "nvim-autopairs")
	if not status_ok then
		return
	end
	local ts_conds = require("nvim-autopairs.ts-conds")
	local npairs = require("nvim-autopairs")
	local Rule = require("nvim-autopairs.rule")
	require("nvim-autopairs").setup({ disable_filetype = { "TelescopePrompt", "vim" } })
	vim.cmd([[packadd nvim-compe]])
	require("nvim-autopairs.completion.compe").setup({
		map_cr = true, --  map <CR> on insert mode
		map_complete = true, -- it will auto insert `(` after select function or method item
	})
	npairs.setup({
		check_ts = true,
		ts_config = {
			lua = { "string" }, -- it will not add pair on that treesitter node
			javascript = { "template_string" },
			java = false, -- don't check treesitter on java
		},
	})
	-- press % => %% is only inside comment or string
	npairs.add_rules({
		Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
		Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
	})
end

return config
