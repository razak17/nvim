local mp = require('keymap.map')
local nmap, vmap, xmap, nnoremap = mp.nmap, mp.vmap, mp.xmap, mp.nnoremap
require('keymap.config')

-- Dial
vim.cmd([[
  nmap <C-a> <Plug>(dial-increment)
  nmap <C-x> <Plug>(dial-decrement)
  vmap <C-a> <Plug>(dial-increment)
  vmap <C-x> <Plug>(dial-decrement)
  vmap g<C-a> <Plug>(dial-increment-additional)
  vmap g<C-x> <Plug>(dial-decrement-additional)
]])

-- TS
nnoremap('<Leader>Ie', ':TSInstallInfo<CR>')
nnoremap('<Leader>Iu', ':TSUpdate<CR>')
nnoremap('<Leader>mw', ':<c-u>MatchupWhereAmI?<CR>')

-- Bookmark
nnoremap('<Leader>me', ':BookmarkToggle<CR>')
nnoremap('<Leader>mb', ':BookmarkPrev<CR>')
nnoremap('<Leader>mk', ':BookmarkNext<CR>')

-- accelerated jk
nmap("n", 'v:lua.enhance_jk_move("n")', {silent = true, expr = true})
nmap("k", 'v:lua.enhance_jk_move("k")', {silent = true, expr = true})

-- Tree
nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

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
nnoremap('<Leader>frf', ':Telescope nvim_files files<CR>')
nnoremap('<Leader>frB', ':Telescope nvim_files bcommits<CR>')
nnoremap('<Leader>frc', ':Telescope nvim_files commits<CR>')
nnoremap('<Leader>frb', ':Telescope nvim_files branches<CR>')
nnoremap('<Leader>frs', ':Telescope nvim_files status<CR>')

nnoremap('<Leader>fdf', ':Telescope dotfiles git_files<CR>')
nnoremap('<Leader>fdB', ':Telescope dotfiles bcommits<CR>')
nnoremap('<Leader>fdc', ':Telescope dotfiles commits<CR>')
nnoremap('<Leader>fdb', ':Telescope dotfiles branches<CR>')
nnoremap('<Leader>fds', ':Telescope dotfiles status<CR>')

nnoremap('<Leader>fem', ':Telescope media_files<CR>')
nnoremap('<Leader>feb', ':Telescope bg_selector<CR>')
