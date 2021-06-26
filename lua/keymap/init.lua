local map = r17.map
local nmap = r17.nmap
local omap = r17.omap
local imap = r17.imap
local smap = r17.smap
local xmap = r17.xmap
local vmap = r17.vmap
local nnoremap = r17.nnoremap
local inoremap = r17.inoremap
local tnoremap = r17.tnoremap

local opts = {expr = true}

require('keymap.config')

-- vim-fold-cycle
nmap("<BS>", "<Plug>(fold-cycle-close)")

-- Compe
inoremap("<C-Space>", "compe#complete()", opts)
inoremap("<C-e>", "compe#close('<C-e>')", opts)
inoremap("<C-f>", "compe#scroll({ 'delta': +4 })", opts)
inoremap("<C-d>", "compe#scroll({ 'delta': -4 })", opts)
imap("<CR>", [[compe#confirm({ 'keys': "\<Plug>delimitMateCR", 'mode': '' })]],
  {noremap = true, expr = true})
-- vsnip
xmap("<C-x>", "<Plug>(vsnip-cut-text)")
xmap("<C-l>", "<Plug>(vsnip-select-text)")
imap("<Tab>", "v:lua.__tab__complete()", opts)
imap("<S-Tab>", "v:lua.__s_tab__complete()", opts)
nnoremap('<Leader>cs', ':VsnipOpen<CR> 1<CR><CR>')
imap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
  opts)
smap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'",
  opts)

-- accelerated jk
nmap("n", 'v:lua.__enhance_jk_move("n")', {silent = true, expr = true})
nmap("k", 'v:lua.__enhance_jk_move("k")', {silent = true, expr = true})

-- vim-eft
nmap(";", "v:lua.__enhance_ft_move(';')", {expr = true})
xmap(";", "v:lua.__enhance_ft_move(';')", {expr = true})
nmap("f", "v:lua.__enhance_ft_move('f')", {expr = true})
xmap("f", "v:lua.__enhance_ft_move('f')", {expr = true})
omap("f", "v:lua.__enhance_ft_move('f')", {expr = true})
nmap("F", "v:lua.__enhance_ft_move('F')", {expr = true})
xmap("F", "v:lua.__enhance_ft_move('F')", {expr = true})
omap("F", "v:lua.__enhance_ft_move('F')", {expr = true})

-- TS
nnoremap('<Leader>Ie', ':TSInstallInfo<CR>')
nnoremap('<Leader>Iu', ':TSUpdate<CR>')
nnoremap('<Leader>mw', ':<c-u>MatchupWhereAmI?<CR>')

-- Symbols Outline
nnoremap('<Leader>vs', ':SymbolsOutline<CR>')

-- trouble
nnoremap('<Leader>vxd', ':TroubleToggle lsp_document_diagnostics<CR>')
nnoremap('<Leader>vxe', ':TroubleToggle quickfix<CR>')
nnoremap('<Leader>vxl', ':TroubleToggle loclist<CR>')
nnoremap('<Leader>vxr', ':TroubleToggle lsp_references<CR>')
nnoremap('<Leader>vxw', ':TroubleToggle lsp_workspace_diagnostics<CR>')

-- Bookmark
nnoremap('<Leader>me', ':BookmarkToggle<CR>')
nnoremap('<Leader>mb', ':BookmarkPrev<CR>')
nnoremap('<Leader>mk', ':BookmarkNext<CR>')

-- markdown preview
nnoremap('<Leader>om', ':MarkdownPreview<CR>')

-- Glow
nnoremap('<Leader>og', ':Glow<CR>')

-- dadbob
nnoremap('<Leader>od', ':DBUIToggle<CR>')

-- Lsp
nnoremap('<Leader>Li', ':LspInfo<CR>')
nnoremap('<Leader>Ll', ':LspLog<CR>')
nnoremap('<Leader>Lr', ':LspRestart<CR>')
nnoremap('<Leader>vv', ':LspToggleVirtualText<CR>')

-- Tree
nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

-- Far
nnoremap("<Leader>Ff", ":Farr --source=vimgrep<CR>")
nnoremap("<Leader>Fd", ":Fardo<CR>")
nnoremap("<Leader>Fi", ":Farf<CR>")
nnoremap("<Leader>Fr", ":Farr --source=rgnvim<CR>")
nnoremap("<Leader>Fz", ":Farundo<CR>")

-- Bufferline
nnoremap('<Leader>bb', ':BufferLineMovePrev<CR>')
nnoremap('<Leader>bn', ':BufferLineMoveNext<CR>')
nnoremap('gb', ':BufferLinePick<CR>')

-- Packer
nnoremap('<Leader>Pc', ':PlugCompile<CR>')
nnoremap('<Leader>PC', ':PlugClean<CR>')
nnoremap('<Leader>Pi', ':PlugInstall<CR>')
nnoremap('<Leader>Ps', ':PlugSync<CR>')
nnoremap('<Leader>PS', ':PlugStatus<CR>')
nnoremap('<Leader>PU', ':PlugUpdate<CR>')

-- FTerm
nnoremap('<F12>', '<CMD>lua require("FTerm").toggle()<CR>')
tnoremap('<F12>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
nnoremap('<leader>eN', '<CMD>lua require("FTerm").open()<CR>')
map('<leader>en', function() __fterm_cmd("node") end)
map('<leader>eg', function() __fterm_cmd("gitui") end)
map('<leader>ep', function() __fterm_cmd("python") end)
map('<leader>er', function() __fterm_cmd("ranger") end)
map('<leader>el', function() __fterm_cmd("lazygit") end)

-- Kommentary
nmap("<leader>/", "<Plug>kommentary_line_default")
nmap("<leader>a/", "<Plug>kommentary_motion_default")
vmap("<leader>/", "<Plug>kommentary_visual_default")

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
nnoremap('<Leader>fva', ':Telescope lsp_range_code_actions<CR>')
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
-- nnoremap('<Leader>frf', ':Telescope nvim_files files<CR>')
-- nnoremap('<Leader>frg', ':Telescope nvim_files git_files<CR>')
-- nnoremap('<Leader>frB', ':Telescope nvim_files bcommits<CR>')
-- nnoremap('<Leader>frc', ':Telescope nvim_files commits<CR>')
-- nnoremap('<Leader>frb', ':Telescope nvim_files branches<CR>')
-- nnoremap('<Leader>frs', ':Telescope nvim_files status<CR>')

-- nnoremap('<Leader>fdf', ':Telescope dotfiles git_files<CR>')
-- nnoremap('<Leader>fdB', ':Telescope dotfiles bcommits<CR>')
-- nnoremap('<Leader>fdc', ':Telescope dotfiles commits<CR>')
-- nnoremap('<Leader>fdb', ':Telescope dotfiles branches<CR>')
-- nnoremap('<Leader>fds', ':Telescope dotfiles status<CR>')

nnoremap('<Leader>fem', ':Telescope media_files<CR>')
nnoremap('<leader>fep', ':Telescope project<CR>')
nnoremap('<Leader>feb', ':Telescope bg_selector<CR>')
