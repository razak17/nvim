local mp = require('keymap.map')
local nmap, vmap, xmap, imap, smap, nnoremap, inoremap = mp.nmap, mp.vmap,
                                                         mp.xmap, mp.imap,
                                                         mp.smap, mp.nnoremap,
                                                         mp.inoremap
local opts = {expr = true}
require('keymap.config')

-- vsnip
xmap("<C-l>", "<Plug>(vsnip-select-text)")
xmap("<C-x>", "<Plug>(vsnip-cut-text)")
imap("<Tab>", "v:lua.tab()", opts)
imap("<S-Tab>", "v:lua.s_tab()", opts)
nnoremap('<Leader>cs', ':VsnipOpen<CR> 1<CR><CR>')
imap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
     opts)
smap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
     opts)

-- Compe
imap("<CR>", [[compe#confirm({ 'keys': "\<Plug>delimitMateCR", 'mode': '' })]],
     {noremap = true, expr = true})
inoremap("<C-Space>", "compe#complete()", opts)
inoremap("<C-e>", "compe#close('<C-e>')", opts)

-- Undo tree
nnoremap("<Leader>au", ":UndotreeToggle<CR>")

-- TS
nnoremap('<Leader>Ie', ':TSInstallInfo<CR>')

-- rnvimr
nnoremap('<Leader>ar', ':RnvimrToggle<CR>')

-- Vista
nnoremap('<Leader>vv', ':Vista!!<CR>')

-- Context
nnoremap('<Leader>cc', ':ContextToggle<CR>')

-- Hop
nnoremap('S', ':HopWord<CR>')
nnoremap('L', ':HopLine<CR>')
-- nnoremap('s', ':HopChar2<CR>')
-- nnoremap('gce', ':HopChar1<CR>')
-- nnoremap('gce', ':HopPattern<CR>')

-- vim-operator-surround
nmap('sa', '<Plug>(operator-surround-append)', {silent = true})
nmap('sd', '<Plug>(operator-surround-delete)', {silent = true})
nmap('sr', '<Plug>(operator-surround-relace)', {silent = true})

-- Bookmark
nnoremap('<Leader>me', ':BookmarkToggle<CR>')
nnoremap('<Leader>mb', ':BookmarkPrev<CR>')
nnoremap('<Leader>mk', ':BookmarkNext<CR>')

-- acceleratedjk
nmap("n", 'v:lua.enhance_jk_move("n")', {silent = true, expr = true})
nmap("k", 'v:lua.enhance_jk_move("k")', {silent = true, expr = true})

-- vim-eft
nmap(";", "v:lua.enhance_ft_move(';')", {expr = true})
xmap(";", "v:lua.enhance_ft_move(';')", {expr = true})
nmap("f", "v:lua.enhance_ft_move('f')", {expr = true})
nmap("f", "v:lua.enhance_ft_move('f')", {expr = true})
nmap("f", "v:lua.enhance_ft_move('f')", {expr = true})
nmap("F", "v:lua.enhance_ft_move('F')", {expr = true})
nmap("F", "v:lua.enhance_ft_move('F')", {expr = true})
nmap("F", "v:lua.enhance_ft_move('F')", {expr = true})

-- markdown preview
nnoremap('<Leader>om', ':MarkdownPreview<CR>')

-- dadbob
nnoremap('<Leader>od', ':DBUIToggle<CR>')

-- Lsp
nnoremap('<Leader>Li', ':LspInfo<CR>')
nnoremap('<Leader>Ll', ':LspLog<CR>')
nnoremap('<Leader>Lr', ':LspRestart<CR>')
nnoremap('<Leader>lf', ':LspFormatting<CR>')
nnoremap('<Leader>lv', ':LspToggleVirtualText<CR>')
nnoremap('<Leader>lx', ':cclose<CR>')

-- Tree
nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

-- Far
nnoremap("<Leader>Ff", ":Farr --source=vimgrep<CR>")
nnoremap("<Leader>Fr", ":Farr --source=rgnvim<CR>")
nnoremap("<Leader>Fd", ":Fardo<CR>")
nnoremap("<Leader>Fz", ":Farf<CR>")

-- Bufferline
nnoremap('<Leader>bb', ':BufferLineMovePrev<CR>')
nnoremap('<Leader>bn', ':BufferLineMoveNext<CR>')
nnoremap('gb', ':BufferLinePick<CR>')

-- Packer
nnoremap('<Leader>Pc', ':PlugCompile<CR>')
nnoremap('<Leader>PC', ':PlugClean<CR>')
nnoremap('<Leader>Pi', ':PlugInstall<CR>')
nnoremap('<Leader>Ps', ':PlugSync<CR>')
nnoremap('<Leader>PU', ':PlugUpdate<CR>')

-- Fugitive
nnoremap("<Leader>ga", ":Git fetch --all<CR>")
nnoremap("<Leader>gA", ":Git blame<CR>")
nnoremap("<Leader>gb", ":GBranches<CR>")
nnoremap("<Leader>gcm", ":Git commit<CR>")
nnoremap("<Leader>gca", ":Git commit --amend -m ")
nnoremap("<Leader>gC", ":Git checkout -b ")
nnoremap("<Leader>gd", ":Git diff<CR>")
nnoremap("<Leader>gD", ":Gdiffsplit<CR>")
nnoremap("<Leader>gh", ":diffget //3<CR>")
nnoremap("<Leader>gi", ":Git init<CR>")
nnoremap("<Leader>gk", ":diffget //2<CR>")
nnoremap("<Leader>gl", ":Git log<CR>")
nnoremap("<Leader>ge", ":Git push<CR>")
nnoremap("<Leader>gp", ":Git poosh<CR>")
nnoremap("<Leader>gP", ":Git pull<CR>")
nnoremap("<Leader>gr", ":GRemove<CR>")
nnoremap("<Leader>gs", ":G<CR>")

-- dap
nnoremap('<leader>dc', '<cmd>lua require"dap".continue()<CR>')
nnoremap('<leader>dso', '<cmd>lua require"dap".step_out()<CR>')
nnoremap('<leader>dsv', '<cmd>lua require"dap".step_over()<CR>')
nnoremap('<leader>dsi', '<cmd>lua require"dap".step_into()<CR>')
nnoremap('<leader>dro', '<cmd>lua require"dap".repl.open()<CR>')
nnoremap('<leader>drl', '<cmd>lua require"dap".repl.run_last()<CR>')
nnoremap('<leader>dbt', '<cmd>lua require"dap".toggle_breakpoint()<CR>')
nnoremap('<leader>dbl',
         '<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>')
nnoremap('<leader>dbs',
         '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')

-- Floaterm
nnoremap("<Leader>ee", ":FloatermToggle<CR>")
nnoremap("<Leader>el", ":FloatermNew lazygit<CR>")
nnoremap("<Leader>en", ":FloatermNew node<CR>")
nnoremap("<Leader>eN", ":FloatermNew<CR>")
nnoremap("<Leader>ep", ":FloatermNew python<CR>")
nnoremap("<Leader>er", ":FloatermNew ranger<CR>")

-- Kommentary
nmap("<leader>/", "<Plug>kommentary_line_default")
nmap("<leader>a/", "<Plug>kommentary_motion_default")
vmap("<leader>/", "<Plug>kommentary_visual_default")

-- Telescope
nnoremap('<Leader>ff', ':Telescope find_files<CR>')
nnoremap('<Leader>fb', ':Telescope file_browser<CR>')
nnoremap('<Leader>frr', ':Telescope oldfiles<CR>')
nnoremap('<Leader>fce', ':Telescope planets<CR>')
nnoremap('<Leader>fcA', ':Telescope autocommands()<CR>')
nnoremap('<Leader>fcb', ':Telescope buffers<CR>')
nnoremap('<Leader>fcc', ':Telescope commands<CR>')
nnoremap('<Leader>fcf', ':Telescope builtin<CR>')
nnoremap('<Leader>fch', ':Telescope help_tags<CR>')
nnoremap('<Leader>fcH', ':Telescope command_history<CR>')
nnoremap('<Leader>fck', ':Telescope keymaps<CR>')
nnoremap('<Leader>fcl', ':Telescope loclist<CR>')
nnoremap('<Leader>fcm', ':Telescope man_pages<CR>')
nnoremap('<Leader>fcr', ':Telescope registers<CR>')
nnoremap('<Leader>fcT', ':Telescope treesitter<CR>')
nnoremap('<Leader>fcv', ':Telescope vim_options<CR>')
nnoremap('<Leader>fcz', ':Telescope current_buffer_fuzzy_find<CR>')
nnoremap('<Leader>fva', ':Telescope lsp_code_action<CR>')
nnoremap('<Leader>fvr', ':Telescope lsp_references<CR>')
nnoremap('<Leader>fvsd', ':Telescope lsp_document_symbols<CR>')
nnoremap('<Leader>fvsw', ':Telescope lsp_workspace_symbols<CR>')
nnoremap('<Leader>flg', ':Telescope live_grep<CR>')
nnoremap('<Leader>flw', ':Telescope grep_string<CR>')
nnoremap('<Leader>fle', ':Telescope grep_string_prompt<CR>')

-- Telescope git
nnoremap('<Leader>fgb', ':Telescope git_branches<CR>')
nnoremap('<Leader>fgc', ':Telescope git_commits<CR>')
nnoremap('<Leader>fgC', ':Telescope git_bcommits<CR>')
nnoremap('<Leader>fgf', ':Telescope git_files<CR>')
nnoremap('<Leader>fgs', ':Telescope git_status<CR>')

-- Telescope extensions
nnoremap('<Leader>frc', ':Telescope dotfiles<CR>')
nnoremap('<Leader>fem', ':Telescope media_files<CR>')
nnoremap('<leader>fep', ':Telescope project<CR>')
nnoremap('<leader>fee', ':Telescope packer plugins<CR>')
nnoremap('<Leader>feb', ':Telescope bg_selector<CR>')

-- telescope-dap
nnoremap('<leader>fdc', ':Telescope dap commands<CR>')
nnoremap('<leader>fdo', ':Telescope dap configurations<CR>')
nnoremap('<leader>fdb', ':Telescope dap list_breakpoints<CR>')
nnoremap('<leader>fdv', ':Telescope dap variables<CR>')
nnoremap('<leader>fdf', ':Telescope dap frames<CR>')
