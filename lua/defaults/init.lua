-- opts
rvim.sets = {
	wrap = false,
	spell = false,
	spelllang = "en",
	textwidth = 80,
	number = true,
	relative_number = true,
	numberwidth = 4,
	shiftwidth = 2,
	tabstop = 2,
	cmdheight = 2,
	scrolloff = 7,
	laststatus = 2,
	showtabline = 2,
	smartcase = true,
	ignorecase = true,
	hlsearch = true,
	timeoutlen = 500,
	foldenable = true,
	foldtext = "v:lua.folds()",
	udir = rvim.__cache_dir .. "/undodir",
	viewdir = rvim.__cache_dir .. "/view",
	directory = rvim.__cache_dir .. "/swap",
}

rvim.plugin = {
	-- SANE defaults
	SANE = { active = true },
	-- debug
	debug = { active = false },
	debug_ui = { active = false },
	dap_install = { active = false },
	osv = { active = false },
	-- lsp
	saga = { active = false },
	lightbulb = { active = true },
	symbols_outline = { active = false },
	bqf = { active = false },
	trouble = { active = false },
	nvim_lint = { active = true },
	formatter = { active = true },
	lsp_ts_utils = { active = true },
	-- treesitter
	treesitter = { active = false },
	playground = { active = true },
	rainbow = { active = false },
	matchup = { active = false },
	autotag = { active = false },
	autopairs = { active = true },
	-- editor
	fold_cycle = { active = false },
	accelerated_jk = { active = false },
	easy_align = { active = false },
	cool = { active = true },
	delimitmate = { active = false },
	eft = { active = false },
	cursorword = { active = true },
	surround = { active = true },
	dial = { active = true },
	-- tools
	fterm = { active = true },
	far = { active = true },
	bookmarks = { active = false },
	colorizer = { active = true },
	undotree = { active = false },
	fugitive = { active = false },
	rooter = { active = true },
	diffview = { active = true },
	-- TODO: handle these later
	glow = { active = false },
	doge = { active = false },
	dadbod = { active = false },
	restconsole = { active = false },
	markdown_preview = { active = true },
	-- aesth
	tree = { active = true },
	dashboard = { active = false },
	statusline = { active = false },
	git_signs = { active = false },
	indent_line = { active = false },
	-- completion
	emmet = { active = false },
	friendly_snippets = { active = true },
	vsnip = { active = true },
	telescope_fzy = { active = false },
	telescope_project = { active = false },
	telescope_media_files = { active = false },
}

rvim.telescope = {
	prompt_prefix = " ❯ ",
	layout_config = { height = 0.9, width = 0.9 },
	borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
}

rvim.nvim_tree = {
	side = "right",
	auto_open = 0,
	width = 35,
	indent_markers = 1,
	lsp_diagnostics = 0,
	special_files = { "README.md", "Makefile", "MAKEFILE" },
}

rvim.treesitter = {
	ensure_installed = {
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"graphql",
		"jsdoc",
		"json",
		"yaml",
		"go",
		"c",
		"dart",
		"cpp",
		"rust",
		"python",
		"bash",
		"lua",
	},
	highlight = { enabled = true },
}

rvim.dashboard = {
	custom_header = {
		"                                                       ",
		"                                                       ",
		" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
		" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
		" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
		" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
		" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
		" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
		"                                                       ",
		"                                                       ",
	},
	default_executive = "telescope",
	disable_statusline = 0,
	save_session = function()
		vim.cmd("SessionSave")
	end,
	session_directory = rvim.__session_dir,
}

rvim.utils = { leader_key = " ", dapinstall_dir = rvim.__data_dir, transparent_window = false }

rvim.lsp = {
	override = {},
	document_highlight = true,
	hover_diagnostics = true,
	format_on_save = true,
	lint_on_save = true,
	rust_tools = false,
	on_attach_callback = nil,
	binary = {
		clangd = "clangd",
		cmake = "cmake-language-server",
		css = "vscode-css-language-server",
		docker = "docker-langserver",
		efm = "efm-langserver",
		elixir = rvim.__elixirls_root_path .. "/.bin/language_server.sh",
		graphql = "graphql-lsp",
		lua = rvim.__sumneko_root_path .. "/bin/Linux/lua-language-server",
		go = "gopls",
		html = "vscode-html-language-server",
		json = "vscode-json-language-server",
		python = "pyright-langserver",
		rust = "rust-analyzer",
		sh = "bash-language-server",
		tsserver = "typescript-language-server",
		vim = "vim-language-server",
		yaml = "yaml-language-server",
	},
}

local schemas = nil
local on_attach = require("lsp").on_attach
local capabilities = require("lsp").capabilities
local lsp_utils = require("lsp.utils")
local status_ok, jsonls_settings = pcall(require, "nlspsettings.jsonls")
if status_ok then
	schemas = jsonls_settings.get_default_schemas()
end

rvim.lang = {
	c = {
		formatter = { exe = "clang_format", args = {}, stdin = true },
		linters = { "clangtidy" },
		lsp = {
			provider = "clangd",
			setup = {
				cmd = {
					rvim.lsp.binary.clangd,
					"--background-index",
					"--header-insertion=never",
					"--cross-file-rename",
					"--clang-tidy",
					"--header-insertion=never",
					"--cross-file-rename",
					"--clang-tidy",
					"--clang-tidy-checks=-*,llvm-*,clang-analyzer-*",
				},
				init_options = {
					clangdFileStatus = true,
					usePlaceholders = true,
					completeUnimported = true,
					semanticHighlighting = true,
				},
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	cmake = {
		formatter = { exe = "clang_format", args = {} },
		linters = {},
		lsp = {
			provider = "cmake",
			setup = {
				cmd = { rvim.lsp.binary.cmake, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lsp_utils.root_dir(),
			},
		},
	},
	cpp = {
		formatter = { exe = "clang_format", args = {}, stdin = true },
		linters = { "cppcheck", "clangtidy" },
		lsp = {
			provider = "clangd",
			setup = {
				cmd = {
					rvim.lsp.binary.clangd,
					"--background-index",
					"--header-insertion=never",
					"--cross-file-rename",
					"--completion-style=bundled",
					"--clang-tidy",
					"--clang-tidy-checks=-*,llvm-*,clang-analyzer-*",
				},
				init_options = {
					clangdFileStatus = true,
					usePlaceholders = true,
					completeUnimported = true,
					semanticHighlighting = true,
				},
				capabilities = capabilities,
				on_attach = on_attach,
			},
		},
	},
	css = {
		formatter = { exe = "prettier", args = {} },
		linters = {},
		lsp = {
			provider = "cssls",
			setup = {
				cmd = { rvim.lsp.binary.css, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lsp_utils.root_dir(),
			},
		},
	},
	docker = {
		formatter = { exe = "", args = {} },
		linters = {},
		lsp = {
			provider = "dockerls",
			setup = {
				cmd = { rvim.lsp.binary.docker, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lsp_utils.root_dir(),
			},
		},
	},
	elixir = {
		formatter = { exe = "mix", args = { "format" }, stdin = true },
		linters = {},
		lsp = {
			provider = "elixirls",
			setup = { cmd = { rvim.lsp.binary.elixir }, capabilities = capabilities, on_attach = on_attach },
		},
	},
	go = {
		formatter = { exe = "gofmt", args = {}, stdin = true },
		linters = { "golangcilint", "revive" },
		lsp = {
			provider = "gopls",
			setup = {
				cmd = { rvim.lsp.binary.go },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	graphql = {
		formatter = { exe = "", args = {} },
		linters = {},
		lsp = {
			provider = "graphql",
			setup = {
				cmd = { rvim.lsp.binary.graphql, "server", "-m", "stream" },
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lsp_utils.root_dir(),
			},
		},
	},
	html = {
		formatter = { exe = "prettier", args = {} },
		linters = {
			"tidy",
			-- https://docs.errata.ai/vale/scoping#html
			"vale",
		},
		lsp = {
			provider = "html",
			setup = {
				cmd = { rvim.lsp.binary.html, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lsp_utils.root_dir(),
			},
		},
	},
	javascript = {
		formatter = { exe = "prettier", args = {} },
		linters = { "eslint" },
		lsp = {
			provider = "tsserver",
			setup = {
				-- TODO:
				cmd = { rvim.lsp.binary.tsserver, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	javascriptreact = {
		-- @usage can be prettier or eslint
		formatter = { exe = "prettier", args = {}, stdin = true },
		linters = { "eslint" },
		lsp = {
			provider = "tsserver",
			setup = {
				-- TODO:
				cmd = { rvim.lsp.binary.tsserver, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	json = {
		formatter = { exe = "python", args = { "-m", "json.tool" }, stdin = true },
		linters = {},
		lsp = {
			provider = "jsonls",
			setup = {
				cmd = { rvim.lsp.binary.json, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lsp_utils.root_dir(),
				settings = {
					json = {
						schemas = schemas,
					},
				},
				commands = {
					Format = {
						function()
							vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
						end,
					},
				},
			},
		},
	},
	lua = {
		formatter = {
			exe = "stylua",
			args = {},
		},
		linters = { "luacheck" },
		lsp = {
			provider = "sumneko_lua",
			setup = {
				cmd = { rvim.lsp.binary.lua, "-E", rvim.__sumneko_root_path .. "/main.lua" },
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
							path = vim.split(package.path, ";"),
						},
						diagnostics = {
							globals = { "vim", "packer_plugins", "rvim" },
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
							},
							maxPreload = 100000,
							preloadFileSize = 1000,
						},
					},
				},
			},
		},
	},
	python = {
		formatter = { exe = "yapf", args = {}, stdin = true },
		linters = { "flake8", "pylint", "mypy" },
		lsp = {
			provider = "pyright",
			setup = {
				cmd = { rvim.lsp.binary.python, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	rust = {
		formatter = { exe = "rustfmt", args = { "--emit=stdout", "--edition=2018" }, stdin = true },
		linters = {},
		lsp = {
			provider = "rust_analyzer",
			setup = { cmd = { rvim.lsp.binary.rust }, on_attach = on_attach, capabilities = capabilities },
		},
	},
	sh = {
		formatter = {
			exe = "shfmt",
			args = {},
		},
		linters = { "shellcheck" },
		lsp = {
			provider = "bashls",
			setup = {
				cmd = { rvim.lsp.binary.sh, "start" },
				cmd_env = { GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)" },
				filetypes = { "sh", "zsh" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	typescript = {
		formatter = { exe = "prettier", args = {} },
		linters = { "eslint" },
		lsp = {
			provider = "tsserver",
			setup = {
				-- TODO:
				cmd = { rvim.lsp.binary.tsserver, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	typescriptreact = {
		formatter = { exe = "prettier", args = {}, stdin = true },
		linters = { "eslint" },
		lsp = {
			provider = "tsserver",
			setup = {
				-- TODO:
				cmd = { rvim.lsp.binary.tsserver, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	vim = {
		formatter = { exe = "", args = {} },
		linters = { "vint" },
		lsp = {
			provider = "vimls",
			setup = {
				cmd = { rvim.lsp.binary.vim, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
	yaml = {
		formatter = {
			exe = "prettier",
			args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote", stdin = true },
			stdin = true,
		},
		linters = {},
		lsp = {
			provider = "yamlls",
			setup = {
				cmd = { rvim.lsp.binary.yaml, "--stdio" },
				on_attach = on_attach,
				capabilities = capabilities,
			},
		},
	},
}
