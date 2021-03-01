local vim = vim
local mappings = require('utils.map')
local nmap, vmap, nnoremap, inoremap, vnoremap, xnoremap, tnoremap = mappings.nmap, mappings.vmap,  mappings.nnoremap, mappings.inoremap, mappings.vnoremap, mappings.xnoremap, mappings.tnoremap

-- Basic Key Mappings
nnoremap('n', 'j')
nnoremap('z', 'u')

-- Yank from cursor position to end-of-line
nnoremap('Y', 'y$')

-- Easier line-wise movement
nnoremap("gh", "g^")
nnoremap("gl", "g$")

-- Move selected line / block of text in visual mode
xnoremap('K', ":move '<-2<CR>gv-gv")
xnoremap('J', ":move '>+1<CR>gv-gv")
xnoremap('N', ":move '>+1<CR>gv-gv")
xnoremap('K', ":m '<-2<CR>gv=gv")
xnoremap('J', ":m '>+1<CR>gv=gv")
xnoremap('N', ":m '>+1<CR>gv=gv")

-- no way
if vim.fn.exists('g:vscode') == 0 then
  -- Open url
  nnoremap('gx', ":sil !xdg-open <c-r><c-a><cr>")

  -- Better Navigation
  nnoremap('<C-h>', '<C-w>h')
  nnoremap('<C-n>', '<C-w>j')
  nnoremap('<C-k>', '<C-w>k')
  nnoremap('<C-l>', '<C-w>l')

  -- Start new line from any cursor position
  inoremap("<S-Return>", "<C-o>o")

  -- g Leader key
  nnoremap('<Space>', '<Nop>')

  -- Remapping the escape key
  inoremap('kj', '<Esc>')
  inoremap('jj', '<Esc>')
  inoremap('jk', '<Esc>')

  -- Easy CAPS
  inoremap('<C-u>', '<Esc>viwUi')
  inoremap('<C-u>', 'viwU<Esc>')

  -- Use alt + hjkl to resize windows
  nnoremap('<M-j>', ':resize -2<CR>')
  nnoremap('<M-k>', ':resize +2<CR>')
  nnoremap('<M-h>', ':vertical resize -2<CR>')
  nnoremap('<M-l>', ':vertical resize +2<CR>')

  -- Window Resize
  -- nnoremap('<Leader>cv', ':wincmd v<bar> :Ex <bar> :vertical resize 30<CR>')
  -- nnoremap('<Leader>cv', ':Sex!<CR> :vertical resize 30<CR>')
  -- nnoremap('<Leader>ca', ':vertical resize 30<CR>')
  nnoremap('<Leader>aF', ':vertical resize 90<CR>')
  nnoremap('<Leader>+', ':vertical resize +5<CR>')
  nnoremap('<Leader>-', ':vertical resize -5<CR>')

  -- Search Files
  nnoremap('<Leader>chw', ':h <C-R>=expand("<cword>")<CR><CR>')
  nnoremap('<Leader>bs', '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>')

  -- Terminal window Navigation
  tnoremap('<C-h>', '<C-\\><C-N><C-w>h')
  tnoremap('<C-j>', '<C-\\><C-N><C-w>j')
  tnoremap('<C-k>', '<C-\\><C-N><C-w>k')
  tnoremap('<C-l>', '<C-\\><C-N><C-w>l')
  inoremap('<C-h>', '<C-\\><C-N><C-w>h')
  inoremap('<C-j>', '<C-\\><C-N><C-w>j')
  inoremap('<C-k>', '<C-\\><C-N><C-w>k')
  inoremap('<C-l>', '<C-\\><C-N><C-w>l')
  tnoremap('<Esc>', '<C-\\><C-N>')

  -- TAB in general mode will move to text buffer, SHIFT-TAB will go back
  nnoremap('<TAB>', ':bnext<CR>')
  nnoremap('<S-TAB>', ':bprevious<CR>')

  -- Tab navigation
  nnoremap('<Leader>sb', ':tabprevious<CR>')
  nnoremap('<Leader>sK', ':tablast<CR>')
  nnoremap('<Leader>sk', ':tabfirst<CR>')
  nnoremap('<Leader>sl', ':tabnext<CR>')
  nnoremap('<Leader>sN', ':tabnew<CR>')
  nnoremap('<Leader>sd', ':tabclose<CR>')
  nnoremap('<Leader>sH', ':-tabmove<CR>')
  nnoremap('<Leader>sL', ':+tabmove<CR>')

  -- Alternate way to save
  nnoremap('<C-s>', ':w<CR>')

  -- Alternate way to quit
  nnoremap('<C-Q>', ':wq!<CR>')
  nnoremap('<Leader>x', ':q<CR>')
  nnoremap('<C-z>', ':undo<CR>')

  -- Use control-c instead of escape
  nnoremap('<C-c>', '<Esc>')

  -- Better tabbing
  vnoremap('<', '<gv')
  vnoremap('>', '>gv')

  -- Greatest remap ever
  vnoremap('<Leader>p', '"_dP')

  -- Next greatest remap ever : asbjornHaland
  nnoremap('<Leader>y', '"+y')
  vnoremap('<Leader>y', '"+y')
  nnoremap('<Leader>aY', 'gg"+yG')
  nnoremap('<Leader>aV', 'gg"+VG')
  nnoremap('<Leader>aD', 'gg"+VGd')

  -- Replace type  with Option<Type>
  vnoremap("<leader>mO", [[:s/\%V\(.*\)\%V/Option<\1>/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace type  with Result<Type, Err>
  vnoremap("<leader>mR", [[:s/\%V\(.*\)\%V/Result<\1, Err>/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace val  with Some(val)
  vnoremap("<leader>ms", [[:s/\%V\(.*\)\%V/Some(\1)/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace val  with Ok(val)
  vnoremap("<leader>mo", [[:s/\%V\(.*\)\%V/Ok(\1)/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace val  with Err(val)
  vnoremap("<leader>me", [[:s/\%V\(.*\)\%V/Err(\1)/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace val  with (val)
  vnoremap("<leader>m(", [[:s/\%V\(.*\)\%V/(\1)/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace val  with 'val'
  vnoremap("<leader>m'", [[:s/\%V\(.*\)\%V/'\1'/ <CR> <bar> :nohlsearch<CR>]])
  -- Replace val  with "val"
  vnoremap("<leader>m\"", [[:s/\%V\(.*\)\%V/"\1"/ <CR> <bar> :nohlsearch<CR>]])

  -- actions
  nnoremap("<Leader>=", "<C-W>=")
  nnoremap("<Leader>ah", "<C-W>s")
  nnoremap("<Leader>an", ":let @/ = ''<CR>")
  nnoremap("<Leader>aN", ":set nonumber!<CR>")
  nnoremap("<Leader>aR", ":set norelativenumber!<CR>")
  nnoremap("<Leader>as", ":wq!<CR>")
  nnoremap("<Leader>au", ":UndotreeToggle<CR>")
  nnoremap("<Leader>av", "<C-W>v")
  nnoremap("<Leader>ax", ":wq!<CR>")
  nnoremap("<Leader>az", ":q!<CR>")

  -- Session
  nnoremap("<Leader>Sc", "SClose<CR>")
  nnoremap("<Leader>Sd", ":SDelete<CR>")
  nnoremap("<Leader>Sl", ":SLoad<CR>")
  nnoremap("<Leader>Ss", ":SSave<CR>")

  -- Folds
  nnoremap("<S-Return>", "zMzvzt")
  nnoremap("<Leader>afl", "za")
  nnoremap("<Leader>afe", ":lua require 'utils.funcs'.ToggleFold()<CR>")

  ------------------------------------------------------------------------------
  -- Plugins
  ------------------------------------------------------------------------------

  -- Packer
  nnoremap('<Leader>Pc', ':PlugCompile<CR>')
  nnoremap('<Leader>PC', ':PlugClean<CR>')
  nnoremap('<Leader>Pi', ':PlugInstall<CR>')
  nnoremap('<Leader>Ps', ':PlugSync<CR>')
  nnoremap('<Leader>PU', ':PlugUpdate<CR>')

  -- Git
  nnoremap("<Leader>ga", ":Git fetch --all<CR>")
  nnoremap("<Leader>gA", ":Git blame<CR>")
  nnoremap("<Leader>gb", ":GBranches<CR>")
  nnoremap("<Leader>gcm", ":Git commit<CR>")
  nnoremap("<Leader>gca", ":Git commit --amend -m ")
  nnoremap("<Leader>gC", ":Git checkout -b ")
  nnoremap("<Leader>gd", ":Git diff<CR>")
  nnoremap("<Leader>gD", ":Gdiffsplit<CR>")
  nnoremap("<Leader>gh", ":diffget //3<CR>")
  nnoremap("<Leader>gk", ":diffget //2<CR>")
  nnoremap("<Leader>gl", ":Git log<CR>")
  nnoremap("<Leader>ge", ":Git push<CR>")
  nnoremap("<Leader>gp", ":Git poosh<CR>")
  nnoremap("<Leader>gP", ":Git pull<CR>")
  nnoremap("<Leader>gr", ":GRemove<CR>")
  nnoremap("<Leader>gs", ":vertical G<CR>")

  -- Floaterm
  nnoremap("<Leader>Te", ":FloatermToggle<CR>")
  nnoremap("<Leader>Tn", ":FloatermNew node<CR>")
  nnoremap("<Leader>TN", ":FloatermNew<CR>")
  nnoremap("<Leader>Tp", ":FloatermNew python<CR>")
  nnoremap("<Leader>Tr", ":FloatermNew ranger<CR>")

  -- Kommentary
  nmap("<leader>/", "<Plug>kommentary_line_default")
  nmap("<leader>a/", "<Plug>kommentary_motion_default")
  vmap("<leader>/", "<Plug>kommentary_visual_default")

  -- Rooter
  nnoremap('<Leader>cR', ':RooterToggle<CR>')

  -- Other remaps
  nnoremap('<Leader><CR>', ':so ~/.config/nvim/init.vim<CR>')
  nnoremap('<Leader>,',    ':e ~/.config/nvim/lua/init.lua<CR>')
  nnoremap('<Leader>.',    ':e $MYVIMRC<CR>')
  nnoremap('<leader>ar',   ':call EmptyRegisters()<CR>')
  nnoremap('<Leader>Ic',   ':checkhealth<CR>')
  nnoremap('<Leader>Ie',   ':TSInstallInfo<CR>')
  nnoremap('<Leader>Ili',  ':LspInfo<CR>')
  nnoremap('<Leader>Ill',  ':LspLog<CR>')
  nnoremap('<leader>ev',   ':ToggleTsVtx<CR>')
  nnoremap('<leader>eh',   ':ToggleTsHlGroups<CR>')
  nnoremap('<Leader>vwm',  ':lua require "utils.funcs".ColorMyPencils()<CR>')
  nnoremap('<Leader>aT',   ':lua require "utils.funcs".OpenTerminal()<CR>')
  nnoremap('<leader>ao',   ':lua require "utils.funcs".TurnOnGuides()<CR>')
  nnoremap('<leader>ae',   ':lua require "utils.funcs".TurnOffGuides()<CR>')
end
