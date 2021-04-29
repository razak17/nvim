local mp = require('keymap.map')
local G = require 'core.global'
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
nnoremap('s', ':HopChar2<CR>')
-- nnoremap('gce', ':HopChar1<CR>')
-- nnoremap('gce', ':HopPattern<CR>')

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
nnoremap('<Leader>frr', ':lua require("telescope.builtin").oldfiles()<CR>')
nnoremap('<Leader>fce', ':lua require"telescope.builtin".planets()<CR>')
nnoremap('<Leader>fcA', ':lua require("telescope.builtin").autocommands()<CR>')
nnoremap('<Leader>fcb', ':lua require("telescope.builtin").buffers()<CR>')
nnoremap('<Leader>fcc', ':lua require("telescope.builtin").commands()<CR>')
nnoremap('<Leader>fcf', ':lua require("telescope.builtin").builtin()<CR>')
nnoremap('<Leader>fch', ':lua require("telescope.builtin").help_tags()<CR>')
nnoremap('<Leader>fcH',
         ':lua require("telescope.builtin").command_history()<CR>')
nnoremap('<Leader>fck', ':lua require("telescope.builtin").keymaps()<CR>')
nnoremap('<Leader>fcl', ':lua require("telescope.builtin").loclist()<CR>')
nnoremap('<Leader>fcr', ':lua require("telescope.builtin").registers()<CR>')
nnoremap('<Leader>fcT', ':lua require("telescope.builtin").treesitter()<CR>')
nnoremap('<Leader>fcv', ':lua require("telescope.builtin").vim_options()<CR>')
nnoremap('<Leader>fcz',
         ':lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>')
nnoremap('<Leader>fva',
         ':lua require("telescope.builtin").lsp_code_action()<CR>')
nnoremap('<Leader>fvr', ':lua require("telescope.builtin").lsp_references()<CR>')
nnoremap('<Leader>fvsd',
         ':lua require("telescope.builtin").lsp_document_symbols()<CR>')
nnoremap('<Leader>fvsw',
         ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>')
nnoremap('<Leader>flg', ':lua require("telescope.builtin").live_grep()<CR>')
nnoremap('<Leader>flw',
         ':lua require("telescope.builtin").grep_string { search = vim.fn.expand("<cword>") }<CR>')
nnoremap('<Leader>fle',
         ':lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ")})<CR>')

-- Telescope git
nnoremap('<Leader>fgb', ':lua require("telescope.builtin").git_branches()<CR>')
nnoremap('<Leader>fgc', ':lua require("telescope.builtin").git_commits()<CR>')
nnoremap('<Leader>fgC', ':lua require("telescope.builtin").git_bcommits()<CR>')
nnoremap('<Leader>fgf', ':lua require("telescope.builtin").git_files()<CR>')
nnoremap('<Leader>fgs', ':lua require("telescope.builtin").git_status()<CR>')

-- Telescope extensions
nnoremap('<leader>fep',
         ':lua require("telescope").extensions.project.project{}<CR>')
nnoremap('<leader>fee',
         ':lua require("telescope").extensions.packer.plugins()<CR>')
nnoremap('<Leader>fem',
         ':lua require("telescope").extensions.media_files.media_files()<CR>')
nnoremap('<Leader>frc',
         ':Telescope dotfiles path=' .. G.home .. '.config/nvim' .. '<CR>')
nnoremap('<Leader>feb', ':Telescope bg_selector<CR>')

-- telescope-dap
nnoremap('<leader>fdc',
         '<cmd>lua require"telescope".extensions.dap.commands{}<CR>')
nnoremap('<leader>fdo',
         '<cmd>lua require"telescope".extensions.dap.configurations{}<CR>')
nnoremap('<leader>fdb',
         '<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>')
nnoremap('<leader>fdv',
         '<cmd>lua require"telescope".extensions.dap.variables{}<CR>')
nnoremap('<leader>fdf',
         '<cmd>lua require"telescope".extensions.dap.frames{}<CR>')
