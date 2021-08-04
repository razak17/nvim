local map = rvim.map
local nmap = rvim.nmap
local omap = rvim.omap
local imap = rvim.imap
local smap = rvim.smap
local xmap = rvim.xmap
local vmap = rvim.vmap
local nnoremap = rvim.nnoremap
local inoremap = rvim.inoremap
local tnoremap = rvim.tnoremap
local vnoremap = rvim.vnoremap

local opts = { expr = true }

require "keymap.config"

if rvim.plugin.SANE.active then
  -- Packer
  nnoremap("<Leader>Ec", ":PlugCompile<CR>")
  nnoremap("<Leader>EC", ":PlugClean<CR>")
  nnoremap("<Leader>Ei", ":PlugInstall<CR>")
  nnoremap("<Leader>Es", ":PlugSync<CR>")
  nnoremap("<Leader>ES", ":PlugStatus<CR>")
  nnoremap("<Leader>Ee", ":PlugUpdate<CR>")

  -- Bufferline
  nnoremap("<tab>", ":BufferLineCycleNext<CR>")
  nnoremap("<s-tab>", ":BufferLineCyclePrev<CR>")
  nnoremap("<Leader>bn", ":BufferLineMoveNext<CR>")
  nnoremap("<Leader>bb", ":BufferLineMovePrev<CR>")
  nnoremap("gb", ":BufferLinePick<CR>")

  -- Compe
  inoremap("<C-Space>", "compe#complete()", opts)
  inoremap("<C-e>", "compe#close('<C-e>')", opts)
  inoremap("<C-f>", "compe#scroll({ 'delta': +4 })", opts)
  inoremap("<C-d>", "compe#scroll({ 'delta': -4 })", opts)

  -- vsnip
  xmap("<C-x>", "<Plug>(vsnip-cut-text)")
  xmap("<C-l>", "<Plug>(vsnip-select-text)")
  imap("<Tab>", "v:lua.tab_complete()", opts)
  imap("<S-Tab>", "v:lua.s_tab_complete()", opts)
  nnoremap("<Leader>cs", ":VsnipOpen<CR> 1<CR><CR>")
  imap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", opts)
  smap("<C-l>", "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", opts)

  -- Kommentary
  nmap("<leader>/", "<Plug>kommentary_line_default")
  nmap("<leader>a/", "<Plug>kommentary_motion_default")
  vmap("<leader>/", "<Plug>kommentary_visual_default")

  -- TS
  nnoremap("<Leader>Ie", ":TSInstallInfo<CR>")
  nnoremap("<Leader>Iu", ":TSUpdate<CR>")

  -- Lsp
  nnoremap("<Leader>Li", ":LspInfo<CR>")
  nnoremap("<Leader>Ll", ":LspLog<CR>")
  nnoremap("<Leader>Lr", ":LspReload<CR>")
  nnoremap("<Leader>vv", ":LspToggleVirtualText<CR>")

  -- Telescope
  nnoremap("<Leader>ff", ":Telescope find_files<CR>")
  nnoremap("<Leader>fb", ":Telescope file_browser<CR>")
  nnoremap("<Leader>frr", ":Telescope oldfiles<CR>")
  nnoremap("<Leader>fca", ":Telescope autocommands<CR>")
  nnoremap("<Leader>fcb", ":Telescope buffers<CR>")
  nnoremap("<Leader>fcc", ":Telescope commands<CR>")
  nnoremap("<Leader>fcf", ":Telescope builtin<CR>")
  nnoremap("<Leader>fch", ":Telescope help_tags<CR>")
  nnoremap("<Leader>fcH", ":Telescope command_history<CR>")
  nnoremap("<Leader>fck", ":Telescope keymaps<CR>")
  nnoremap("<Leader>fcl", ":Telescope loclist<CR>")
  nnoremap("<Leader>fce", ":Telescope quickfix<CR>")
  nnoremap("<Leader>fcr", ":Telescope registers<CR>")
  nnoremap("<Leader>fcT", ":Telescope treesitter<CR>")
  nnoremap("<Leader>fcv", ":Telescope vim_options<CR>")
  nnoremap("<Leader>fcz", ":Telescope current_buffer_fuzzy_find<CR>")
  nnoremap("<Leader>fC", ":e " .. vim.g.vim_path .. "/lua/core/config.lua<CR>")

  -- Telescope lsp
  nnoremap("<Leader>fva", ":Telescope lsp_range_code_actions<CR>")
  nnoremap("<Leader>fvr", ":Telescope lsp_references<CR>")
  nnoremap("<Leader>fvd", ":Telescope lsp_document_symbols<CR>")
  nnoremap("<Leader>fvw", ":Telescope lsp_workspace_symbols<CR>")

  -- Telescope grep
  nnoremap("<Leader>fle", ":Telescope grep_string_prompt<CR>")
  nnoremap("<Leader>flg", ":Telescope live_grep<CR>")
  nnoremap("<Leader>flw", ":Telescope grep_string<CR>")

  -- Telescope git
  nnoremap("<Leader>fgb", ":Telescope git_branches<CR>")
  nnoremap("<Leader>fgc", ":Telescope git_commits<CR>")
  nnoremap("<Leader>fgC", ":Telescope git_bcommits<CR>")
  nnoremap("<Leader>fgf", ":Telescope git_files<CR>")
  nnoremap("<Leader>fgs", ":Telescope git_status<CR>")

  -- Telescope extensions
  nnoremap("<Leader>frf", ":Telescope nvim_files files<CR>")
  nnoremap("<Leader>frg", ":Telescope nvim_files git_files<CR>")
  nnoremap("<Leader>frB", ":Telescope nvim_files bcommits<CR>")
  nnoremap("<Leader>frc", ":Telescope nvim_files commits<CR>")
  nnoremap("<Leader>frb", ":Telescope nvim_files branches<CR>")
  nnoremap("<Leader>frs", ":Telescope nvim_files status<CR>")

  nnoremap("<Leader>fdf", ":Telescope dotfiles git_files<CR>")
  nnoremap("<Leader>fdB", ":Telescope dotfiles bcommits<CR>")
  nnoremap("<Leader>fdc", ":Telescope dotfiles commits<CR>")
  nnoremap("<Leader>fdb", ":Telescope dotfiles branches<CR>")
  nnoremap("<Leader>fds", ":Telescope dotfiles status<CR>")

  nnoremap("<Leader>feb", ":Telescope bg_selector<CR>")

  if rvim.plugin.telescope_media_files.active then
    nnoremap("<leader>fep", ":Telescope project<CR>")
  end
  if rvim.plugin.telescope_project.active then
    nnoremap("<Leader>fem", ":Telescope media_files<CR>")
  end
  if rvim.plugin.matchup.active then
    nnoremap("<Leader>vW", ":<c-u>MatchupWhereAmI?<CR>")
  end
end

-- vim-fold-cycle
if rvim.plugin.fold_cycle.active then
  nmap("<BS>", "<Plug>(fold-cycle-close)")
end

-- Easy-align
if rvim.plugin.easy_align.active then
  vmap("<Enter>", "<Plug>(EasyAlign)")
  nmap("ga", "<Plug>(EasyAlign)")
  xmap("ga", "<Plug>(EasyAlign)")
end

-- accelerated jk
if rvim.plugin.accelerated_jk.active or rvim.plugin.SANE.active then
  nmap("n", 'v:lua.enhance_jk_move("n")', { silent = true, expr = true })
  nmap("k", 'v:lua.enhance_jk_move("k")', { silent = true, expr = true })
end

-- vim-eft
if rvim.plugin.eft.active then
  nmap(";", "v:lua.enhance_ft_move(';')", { expr = true })
  xmap(";", "v:lua.enhance_ft_move(';')", { expr = true })
  nmap("f", "v:lua.enhance_ft_move('f')", { expr = true })
  xmap("f", "v:lua.enhance_ft_move('f')", { expr = true })
  omap("f", "v:lua.enhance_ft_move('f')", { expr = true })
  nmap("F", "v:lua.enhance_ft_move('F')", { expr = true })
  xmap("F", "v:lua.enhance_ft_move('F')", { expr = true })
  omap("F", "v:lua.enhance_ft_move('F')", { expr = true })
end

-- Symbols Outline
if rvim.plugin.symbols_outline.active then
  nnoremap("<Leader>vs", ":SymbolsOutline<CR>")
end

-- trouble
if rvim.plugin.trouble.active then
  nnoremap("<Leader>vxd", ":TroubleToggle lsp_document_diagnostics<CR>")
  nnoremap("<Leader>vxe", ":TroubleToggle quickfix<CR>")
  nnoremap("<Leader>vxl", ":TroubleToggle loclist<CR>")
  nnoremap("<Leader>vxr", ":TroubleToggle lsp_references<CR>")
  nnoremap("<Leader>vxw", ":TroubleToggle lsp_workspace_diagnostics<CR>")
end

-- Bookmark
if rvim.plugin.bookmarks.active then
  nnoremap("<Leader>me", ":BookmarkToggle<CR>")
  nnoremap("<Leader>mb", ":BookmarkPrev<CR>")
  nnoremap("<Leader>mk", ":BookmarkNext<CR>")
end

-- markdown preview
if rvim.plugin.markdown_preview.active then
  nnoremap("<Leader>om", ":MarkdownPreview<CR>")
end

-- Glow
if rvim.plugin.glow.active then
  nnoremap("<Leader>og", ":Glow<CR>")
end

-- dadbob
if rvim.plugin.dadbod.active then
  nnoremap("<Leader>od", ":DBUIToggle<CR>")
end

-- UndoTree
if rvim.plugin.undotree.active then
  nnoremap("<Leader>au", ":UndotreeToggle<CR>")
end

-- Tree
if rvim.plugin.tree.active or rvim.plugin.SANE.active then
  nnoremap("<Leader>cr", ":NvimTreeRefresh<CR>")
  nnoremap("<Leader>cf", ":NvimTreeFindFile<CR>")
end

-- Far
if rvim.plugin.far.active then
  nnoremap("<Leader>Ff", ":Farr --source=vimgrep<CR>")
  nnoremap("<Leader>Fd", ":Fardo<CR>")
  nnoremap("<Leader>Fi", ":Farf<CR>")
  nnoremap("<Leader>Fr", ":Farr --source=rgnvim<CR>")
  nnoremap("<Leader>Fz", ":Farundo<CR>")
end

-- FTerm
if rvim.plugin.fterm.active or rvim.plugin.SANE.active then
  nnoremap("<F12>", '<CMD>lua require("FTerm").toggle()<CR>')
  tnoremap("<F12>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  nnoremap("<leader>eN", '<CMD>lua require("FTerm").open()<CR>')
  map("<leader>en", function()
    fterm_cmd "node"
  end)
  map("<leader>eg", function()
    fterm_cmd "gitui"
  end)
  map("<leader>ep", function()
    fterm_cmd "python"
  end)
  map("<leader>er", function()
    fterm_cmd "ranger"
  end)
  map("<leader>el", function()
    fterm_cmd "lazygit"
  end)
end

-- Fugitive
if rvim.plugin.fugitive.active then
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
if rvim.plugin.debug.active then
  nnoremap("<Leader>dso", ':lua require"dap".step_out()<CR>')
  nnoremap("<Leader>dsv", ':lua require"dap".step_over()<CR>')
  nnoremap("<Leader>dsi", ':lua require"dap".step_into()<CR>')
  nnoremap("<Leader>dsb", ':lua require"dap".step_back()<CR>')
  nnoremap("<leader>da", ':lua require"debug.utils".attach()<CR>')
  nnoremap("<leader>dA", ':lua require"debug.utils".attachToRemote()<CR>')
  nnoremap("<leader>db", ':lua require"dap".toggle_breakpoint()<CR>')
  nnoremap("<leader>dB", ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
  nnoremap("<leader>dc", ':lua require"dap".continue()<CR>')
  nnoremap("<leader>dC", ':lua require"dap".run_to_cursor()<CR>')
  nnoremap("<leader>dE", ':lua require"dap".repl.toggle()<CR>')
  nnoremap("<leader>dg", ':lua require"dap".session()<CR>')
  nnoremap("<leader>dk", ':lua require"dap".up()<CR>')
  nnoremap("<leader>dL", ':lua require"dap".run_last()<CR>')
  nnoremap("<leader>dn", ':lua require"dap".down()<CR>')
  nnoremap("<leader>dp", ':lua require"dap".pause.toggle()<CR>')
  nnoremap("<leader>dr", ':lua require"dap".repl.open({}, "vsplit")<CR><C-w>l')
  nnoremap("<leader>dS", ':lua require"dap".stop()<CR>')
  nnoremap("<leader>dx", ':lua require"dap".disconnect()<CR>')
end

-- osv
if rvim.plugin.osv.active then
  nnoremap("<leader>dl", ':lua require"osv".launch()<CR>')
end

-- dapui
if rvim.plugin.debug_ui.active then
  nnoremap("<leader>de", ':lua require"dapui".toggle()<CR>')
  nnoremap("<leader>di", ':lua require"dap.ui.variables".hover()<CR>')
  -- nnoremap('<leader>di', ':lua require"dap.ui.widgets".hover()<CR>')
  vnoremap("<leader>di", ':lua require"dap.ui.variables".visual_hover()<CR>')
  vnoremap("<leader>d?", ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>')
end
