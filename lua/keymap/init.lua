local map = core.map
local nmap = core.nmap
local omap = core.omap
local imap = core.imap
local smap = core.smap
local xmap = core.xmap
local vmap = core.vmap
local nnoremap = core.nnoremap
local inoremap = core.inoremap
local tnoremap = core.tnoremap
local vnoremap = core.vnoremap

local opts = {expr = true}

require('keymap.config')

-- vim-fold-cycle
if core.plugin.fold_cycle.active then nmap("<BS>", "<Plug>(fold-cycle-close)") end

-- Compe
inoremap("<C-Space>", "compe#complete()", opts)
inoremap("<C-e>", "compe#close('<C-e>')", opts)
inoremap("<C-f>", "compe#scroll({ 'delta': +4 })", opts)
inoremap("<C-d>", "compe#scroll({ 'delta': -4 })", opts)
imap("<CR>", [[compe#confirm('<CR>')]], {noremap = true, expr = true})

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

-- Easy-align
if core.plugin.easy_align.active then
  vmap('<Enter>', '<Plug>(EasyAlign)')
  nmap('ga', '<Plug>(EasyAlign)')
  xmap('ga', '<Plug>(EasyAlign)')
end

-- accelerated jk
if core.plugin.accelerated_jk.active or core.plugin.SANE.active then
  nmap("n", 'v:lua.__enhance_jk_move("n")', {silent = true, expr = true})
  nmap("k", 'v:lua.__enhance_jk_move("k")', {silent = true, expr = true})
end

-- vim-eft
if core.plugin.eft.active then
  nmap(";", "v:lua.__enhance_ft_move(';')", {expr = true})
  xmap(";", "v:lua.__enhance_ft_move(';')", {expr = true})
  nmap("f", "v:lua.__enhance_ft_move('f')", {expr = true})
  xmap("f", "v:lua.__enhance_ft_move('f')", {expr = true})
  omap("f", "v:lua.__enhance_ft_move('f')", {expr = true})
  nmap("F", "v:lua.__enhance_ft_move('F')", {expr = true})
  xmap("F", "v:lua.__enhance_ft_move('F')", {expr = true})
  omap("F", "v:lua.__enhance_ft_move('F')", {expr = true})
end

-- TS
nnoremap('<Leader>Ie', ':TSInstallInfo<CR>')
nnoremap('<Leader>Iu', ':TSUpdate<CR>')
nnoremap('<Leader>aw', ':<c-u>MatchupWhereAmI?<CR>')

-- Symbols Outline
nnoremap('<Leader>vs', ':SymbolsOutline<CR>')

-- trouble
if core.plugin.trouble.active then
  nnoremap('<Leader>vxd', ':TroubleToggle lsp_document_diagnostics<CR>')
  nnoremap('<Leader>vxe', ':TroubleToggle quickfix<CR>')
  nnoremap('<Leader>vxl', ':TroubleToggle loclist<CR>')
  nnoremap('<Leader>vxr', ':TroubleToggle lsp_references<CR>')
  nnoremap('<Leader>vxw', ':TroubleToggle lsp_workspace_diagnostics<CR>')
end

-- Bookmark
if core.plugin.bookmarks.active then
  nnoremap('<Leader>me', ':BookmarkToggle<CR>')
  nnoremap('<Leader>mb', ':BookmarkPrev<CR>')
  nnoremap('<Leader>mk', ':BookmarkNext<CR>')
end

-- markdown preview
if core.plugin.markdown_preview.active then
  nnoremap('<Leader>om', ':MarkdownPreview<CR>')
end

-- Glow
if core.plugin.glow.active then nnoremap('<Leader>og', ':Glow<CR>') end

-- dadbob
if core.plugin.dadbod.active then nnoremap('<Leader>od', ':DBUIToggle<CR>') end

-- Lsp
nnoremap('<Leader>Li', ':LspInfo<CR>')
nnoremap('<Leader>Ll', ':LspLog<CR>')
nnoremap('<Leader>Lr', ':LspRestart<CR>')
nnoremap('<Leader>vv', ':LspToggleVirtualText<CR>')

-- UndoTree
if core.plugin.undotree.active then nnoremap('<Leader>au', ':UndotreeToggle<CR>') end

-- Tree
if core.plugin.tree.active or core.plugin.SANE.active then
  nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
  nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
  nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')
end

-- Far
if core.plugin.far.active then
  nnoremap("<Leader>Ff", ":Farr --source=vimgrep<CR>")
  nnoremap("<Leader>Fd", ":Fardo<CR>")
  nnoremap("<Leader>Fi", ":Farf<CR>")
  nnoremap("<Leader>Fr", ":Farr --source=rgnvim<CR>")
  nnoremap("<Leader>Fz", ":Farundo<CR>")
end

-- Bufferline
nnoremap('<Leader>bb', ':BufferLineMovePrev<CR>')
nnoremap('<Leader>bn', ':BufferLineMoveNext<CR>')
nnoremap('gb', ':BufferLinePick<CR>')

-- Packer
nnoremap('<Leader>Ec', ':PlugCompile<CR>')
nnoremap('<Leader>EC', ':PlugClean<CR>')
nnoremap('<Leader>Ei', ':PlugInstall<CR>')
nnoremap('<Leader>Es', ':PlugSync<CR>')
nnoremap('<Leader>ES', ':PlugStatus<CR>')
nnoremap('<Leader>Ee', ':PlugUpdate<CR>')

-- FTerm
if core.plugin.fterm.active or core.plugin.SANE.active then
  nnoremap('<F12>', '<CMD>lua require("FTerm").toggle()<CR>')
  tnoremap('<F12>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  nnoremap('<leader>eN', '<CMD>lua require("FTerm").open()<CR>')
  map('<leader>en', function() __fterm_cmd("node") end)
  map('<leader>eg', function() __fterm_cmd("gitui") end)
  map('<leader>ep', function() __fterm_cmd("python") end)
  map('<leader>er', function() __fterm_cmd("ranger") end)
  map('<leader>el', function() __fterm_cmd("lazygit") end)
end

-- Kommentary
nmap("<leader>/", "<Plug>kommentary_line_default")
nmap("<leader>a/", "<Plug>kommentary_motion_default")
vmap("<leader>/", "<Plug>kommentary_visual_default")

-- Fugitive
if core.plugin.fugitive.active then
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
end

-- dap
if core.plugin.debug.active then
  nnoremap('<Leader>dso', ':lua require"dap".step_out()<CR>')
  nnoremap('<Leader>dsv', ':lua require"dap".step_over()<CR>')
  nnoremap('<Leader>dsi', ':lua require"dap".step_into()<CR>')
  nnoremap('<Leader>dsb', ':lua require"dap".step_back()<CR>')
  nnoremap('<leader>da', ':lua require"debug.helper".attach()<CR>')
  nnoremap('<leader>dA', ':lua require"debug.helper".attachToRemote()<CR>')
  nnoremap('<leader>db', ':lua require"dap".toggle_breakpoint()<CR>')
  nnoremap('<leader>dB',
    ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
  nnoremap('<leader>dc', ':lua require"dap".continue()<CR>')
  nnoremap('<leader>dC', ':lua require"dap".run_to_cursor()<CR>')
  nnoremap('<leader>dE', ':lua require"dap".repl.toggle()<CR>')
  nnoremap('<leader>dg', ':lua require"dap".session()<CR>')
  nnoremap('<leader>dk', ':lua require"dap".up()<CR>')
  nnoremap('<leader>dl', ':lua require"osv".launch()<CR>')
  nnoremap('<leader>dL', ':lua require"dap".run_last()<CR>')
  nnoremap('<leader>dn', ':lua require"dap".down()<CR>')
  nnoremap('<leader>dp', ':lua require"dap".pause.toggle()<CR>')
  nnoremap('<leader>dr', ':lua require"dap".repl.open({}, "vsplit")<CR><C-w>l')
  nnoremap('<leader>dS', ':lua require"dap".stop()<CR>')
  nnoremap('<leader>dx', ':lua require"dap".disconnect()<CR>')
end

-- dapui
if core.plugin.debug_ui.active then
  nnoremap('<leader>de', ':lua require"dapui".toggle()<CR>')
  nnoremap('<leader>di', ':lua require"dap.ui.variables".hover()<CR>')
  -- nnoremap('<leader>di', ':lua require"dap.ui.widgets".hover()<CR>')
  vnoremap('<leader>di', ':lua require"dap.ui.variables".visual_hover()<CR>')
  vnoremap('<leader>d?',
    ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>')
end

-- Telescope
nnoremap('<Leader>ff', ':Telescope find_files<CR>')
nnoremap('<Leader>fb', ':Telescope file_browser<CR>')
nnoremap('<Leader>frr', ':Telescope oldfiles<CR>')
nnoremap('<Leader>fca', ':Telescope autocommands<CR>')
nnoremap('<Leader>fcb', ':Telescope buffers<CR>')
nnoremap('<Leader>fcc', ':Telescope commands<CR>')
nnoremap('<Leader>fcf', ':Telescope builtin<CR>')
nnoremap('<Leader>fch', ':Telescope help_tags<CR>')
nnoremap('<Leader>fcH', ':Telescope command_history<CR>')
nnoremap('<Leader>fck', ':Telescope keymaps<CR>')
nnoremap('<Leader>fcl', ':Telescope loclist<CR>')
nnoremap('<Leader>fcr', ':Telescope registers<CR>')
nnoremap('<Leader>fcT', ':Telescope treesitter<CR>')
nnoremap('<Leader>fcv', ':Telescope vim_options<CR>')
nnoremap('<Leader>fcz', ':Telescope current_buffer_fuzzy_find<CR>')

-- Telescope lsp
nnoremap('<Leader>fva', ':Telescope lsp_range_code_actions<CR>')
nnoremap('<Leader>fvr', ':Telescope lsp_references<CR>')
nnoremap('<Leader>fvd', ':Telescope lsp_document_symbols<CR>')
nnoremap('<Leader>fvw', ':Telescope lsp_workspace_symbols<CR>')

-- Telescope grep
nnoremap('<Leader>fle', ':Telescope grep_string_prompt<CR>')
nnoremap('<Leader>flg', ':Telescope live_grep<CR>')
nnoremap('<Leader>flw', ':Telescope grep_string<CR>')

-- Telescope git
nnoremap('<Leader>fgb', ':Telescope git_branches<CR>')
nnoremap('<Leader>fgc', ':Telescope git_commits<CR>')
nnoremap('<Leader>fgC', ':Telescope git_bcommits<CR>')
nnoremap('<Leader>fgf', ':Telescope git_files<CR>')
nnoremap('<Leader>fgs', ':Telescope git_status<CR>')

-- Telescope extensions
nnoremap('<Leader>frf', ':Telescope nvim_files files<CR>')
nnoremap('<Leader>frg', ':Telescope nvim_files git_files<CR>')
nnoremap('<Leader>frB', ':Telescope nvim_files bcommits<CR>')
nnoremap('<Leader>frc', ':Telescope nvim_files commits<CR>')
nnoremap('<Leader>fC', ':e ' .. core.__vim_path .. '/lua/core/defaults.lua<CR>')
nnoremap('<Leader>frb', ':Telescope nvim_files branches<CR>')
nnoremap('<Leader>frs', ':Telescope nvim_files status<CR>')

nnoremap('<Leader>fdf', ':Telescope dotfiles git_files<CR>')
nnoremap('<Leader>fdB', ':Telescope dotfiles bcommits<CR>')
nnoremap('<Leader>fdc', ':Telescope dotfiles commits<CR>')
nnoremap('<Leader>fdb', ':Telescope dotfiles branches<CR>')
nnoremap('<Leader>fds', ':Telescope dotfiles status<CR>')

nnoremap('<Leader>fem', ':Telescope media_files<CR>')
nnoremap('<leader>fep', ':Telescope project<CR>')
nnoremap('<Leader>feb', ':Telescope bg_selector<CR>')
