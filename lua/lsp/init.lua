local lsp_config = {}
local command = rvim.command
local is_table = rvim.is_table
local is_string = rvim.is_string
local has_value = rvim.has_value
local lsp_utils = require("lsp.utils")

local function lsp_highlight_document(client)
	if rvim.lsp.document_highlight == false then
		return -- we don't need further
	end
	-- Set autocommands conditional on server_capabilities
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceText cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

command({
	"LspLog",
	function()
		local path = vim.lsp.get_log_path()
		vim.cmd("edit " .. path)
	end,
})

command({
	"LspFormat",
	function()
		vim.lsp.buf.formatting(vim.g[string.format("format_options_%s", vim.bo.filetype)] or {})
	end,
})

command({
	"LspToggleVirtualText",
	function()
		local virtual_text = {}
		virtual_text.show = true
		virtual_text.show = not virtual_text.show
		vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text.show })
	end,
})

local function lsp_mappings()
	local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
	local lsp_popup = { show_header = false, border = "single", focusable = false }

	nnoremap("gd", vim.lsp.buf.definition)
	nnoremap("gD", vim.lsp.buf.declaration)
	nnoremap("gr", vim.lsp.buf.references)
	nnoremap("gi", vim.lsp.buf.implementation)
	nnoremap("K", vim.lsp.buf.hover)
	nnoremap("<Leader>vdb", function()
		vim.lsp.diagnostic.goto_prev({ popup_opts = lsp_popup })
	end)
	nnoremap("<Leader>vdn", function()
		vim.lsp.diagnostic.goto_next({ popup_opts = lsp_popup })
	end)
	nnoremap("<Leader>vdl", function()
		vim.lsp.diagnostic.show_line_diagnostics({ popup_opts = lsp_popup })
	end)
	nnoremap("ge", function()
		require("lsp.utils").PeekDefinition()
	end)
	nnoremap("gE", vim.lsp.buf.type_definition)
	nnoremap("grn", vim.lsp.buf.rename)
	nnoremap("gI", vim.lsp.buf.incoming_calls)
	nnoremap("<leader>va", vim.lsp.buf.code_action)
	vnoremap("<leader>vA", vim.lsp.buf.range_code_action)
	nnoremap("gsd", vim.lsp.buf.document_symbol)
	nnoremap("gsw", vim.lsp.buf.workspace_symbol)
	nnoremap("<leader>vf", ":LspFormat<CR>")
	nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist)
end

function rvim.lsp.tagfunc(pattern, flags)
	if flags ~= "c" then
		return vim.NIL
	end
	local params = vim.lsp.util.make_position_params()
	local client_id_to_results, err = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 500)
	assert(not err, vim.inspect(err))

	local results = {}
	for _, lsp_results in ipairs(client_id_to_results) do
		for _, location in ipairs(lsp_results.result or {}) do
			local start = location.range.start
			table.insert(results, {
				name = pattern,
				filename = vim.uri_to_fname(location.uri),
				cmd = string.format("call cursor(%d, %d)", start.line + 1, start.character + 1),
			})
		end
	end
	return results
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" },
}
capabilities.textDocument.codeAction = {
	dynamicRegistration = false,
	codeActionLiteralSupport = {
		codeActionKind = {
			valueSet = (function()
				local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
				table.sort(res)
				return res
			end)(),
		},
	},
}
lsp_config.capabilities = capabilities

lsp_config.on_attach = function(client, bufnr)
	if client.resolved_capabilities.goto_definition then
		vim.bo[bufnr].tagfunc = "v:lua.core.lsp.tagfunc"
	end
	lsp_highlight_document(client)
end

local function no_formatter_on_attach(client, bufnr)
	if rvim.lsp.on_attach_callback then
		rvim.lsp.on_attach_callback(client, bufnr)
	end
	lsp_highlight_document(client)
	client.resolved_capabilities.document_formatting = false
end

function lsp_config.setup_servers()
	require("lsp").setup("c")
	require("lsp").setup("cmake")
	require("lsp").setup("cpp")
	require("lsp").setup("css")
	require("lsp").setup("docker")
	require("lsp").setup("elixir")
	require("lsp").setup("go")
	require("lsp").setup("graphql")
	require("lsp").setup("html")
	require("lsp").setup("json")
	require("lsp").setup("lua")
	require("lsp").setup("python")
	require("lsp").setup("rust")
	require("lsp").setup("sh")
	require("lsp").setup("vim")
	require("lsp").setup("yaml")
	require("lsp").setup("javascript")
	require("lsp").setup("javascriptreact")
	require("lsp").setup("typescript")

	vim.cmd("doautocmd User LspServersStarted")
end

function lsp_config.setup_handlers()
	vim.fn.sign_define({
		{ name = "LspDiagnosticsSignError", text = "", texthl = "LspDiagnosticsSignError" },
		{ name = "LspDiagnosticsSignHint", text = "", texthl = "LspDiagnosticsSignHint" },
		{ name = "LspDiagnosticsSignWarning", text = "", texthl = "LspDiagnosticsSignWarning" },
		{ name = "LspDiagnosticsSignInformation", text = "", texthl = "LspDiagnosticsSignInformation" },
	})

	vim.lsp.protocol.CompletionItemKind = {
		"   (Text) ",
		"   (Method)",
		" ƒ  (Function)",
		"   (Constructor)",
		" ﴲ  (Field)",
		"   (Variable)",
		"   (Class)",
		" ﰮ  (Interface)",
		"   (Module)",
		" 襁 (Property)",
		"   (Unit)",
		"   (Value)",
		" 了 (Enum)",
		"   (Keyword)",
		"   (Snippet)",
		"   (Color)",
		"   (File)",
		"   (Reference)",
		"   (Folder)",
		"   (EnumMember)",
		"   (Constant)",
		" ﳤ  (Struct)",
		" 鬒 (Event)",
		"   (Operator)",
		"   (TypeParameter)",
	}
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		update_in_insert = false,
		virtual_text = { spacing = 0, prefix = "" },
		signs = true,
	})

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		show_header = false,
		border = rvim.lsp.popup_border,
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
		vim.lsp.handlers.signature_help,
		{ border = rvim.lsp.popup_border }
	)

	lsp_config.setup_servers()
	lsp_utils.toggle_autoformat()
	lsp_utils.lspLocList()
	lsp_mappings()
	if rvim.lsp.hover_diagnostics then
		lsp_utils.hover_diagnostics()
	end
end

function lsp_config.setup(lang)
	local lang_server = rvim.lang[lang].lsp
	local provider = lang_server.provider
	if lsp_utils.check_lsp_client_active(provider) then
		return
	end

	local overrides = rvim.lsp.override

	if is_table(overrides) then
		if has_value(overrides, lang) then
			return
		end
	end

	if is_string(overrides) then
		if overrides == lang then
			return
		end
	end
	local sources = require("lsp.null-ls").setup(lang)

	for _, source in pairs(sources) do
		local method = source.method
		local format_method = "NULL_LS_FORMATTING"

		if is_table(method) then
			if has_value(method, format_method) then
				lang_server.setup.on_attach = no_formatter_on_attach
			end
		end

		if is_string(method) then
			if method == format_method then
				lang_server.setup.on_attach = no_formatter_on_attach
			end
		end
	end

	if provider == "" or provider == nil then
		return
	end

	require("lspconfig")[provider].setup(lang_server.setup)
end

return lsp_config
