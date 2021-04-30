local vim = vim
-- local opt = {noremap = true }
local opts = {noremap = true, silent = true}
local mapk = vim.api.nvim_set_keymap

-- Basic Key Mappings
mapk('n', 'n', 'j', opts)
mapk('n', 'z', 'u', opts)

-- Open url
mapk('n', 'gx', ":sil !xdg-open <c-r><c-a><cr>", opts)

-- Move selected line / block of text in visual mode
-- shift + k to move up
-- shift + j to move down
mapk('x', 'K', ":move '<-2<CR>gv-gv", opts)
mapk('x', 'J', ":move '>+1<CR>gv-gv", opts)
mapk('x', 'N', ":move '>+1<CR>gv-gv", opts)


if vim.fn.exists('vim.g.vscode') == 0 then
  -- Better Navigation
  mapk('n', '<C-h>', '<C-w>h', opts)
  mapk('n', '<C-j>', '<C-w>j', opts)
  mapk('n', '<C-k>', '<C-w>k', opts)
  mapk('n', '<C-l>', '<C-w>l', opts)

  -- g Leader key
  mapk('n', '<Space>', '<Nop>', opts)

  -- Remapping the escape key
  mapk('i', 'kj', '<Esc>', opts)
  mapk('i', 'jj', '<Esc>', opts)
  mapk('i', 'jk', '<Esc>', opts)

  -- Easy CAPS
  mapk('i', '<C-u>', '<Esc>viwUi', opts)
  mapk('i', '<C-u>', 'viwU<Esc>', opts)

  -- Use alt + hjkl to resize windows
  mapk('n', '<M-j>', ':resize -2<CR>', opts)
  mapk('n', '<M-k>', ':resize +2<CR>', opts)
  mapk('n', '<M-h>', ':vertical resize -2<CR>', opts)
  mapk('n', '<M-l>', ':vertical resize +2<CR>', opts)

  -- Fast Commentsc
  mapk('n', '<space>/', ':Commentary<CR>', opts)
  mapk('v', '<space>/', ':Commentary<CR>', opts)

  -- Window Resize
  -- mapk('n', '<Leader>cv', ':wincmd v<bar> :Ex <bar> :vertical resize 30<CR>', opts)
  mapk('n', '<Leader>+', ':vertical resize +5<CR>', opts)
  mapk('n', '<Leader>-', ':vertical resize -5<CR>', opts)

  -- Search Files
  -- mapk('n', '<C-k>', ':Files<CR>', opts)
  -- mapk('n', '<Leader>cw', ':Rg <C-R>=expand("<cword>")<CR><CR>', opts)
  -- mapk('n', '<Leader>cs', ':Rg<SPACE>', opts)
  mapk('n', '<Leader>chw', ':h <C-R>=expand("<cword>")<CR><CR>', opts)
  mapk('n', '<Leader>bs', '/<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>', opts)

  -- Terminal window Navigation
  mapk('t', '<C-h>', '<C-\\><C-N><C-w>h', opts)
  mapk('t', '<C-j>', '<C-\\><C-N><C-w>j', opts)
  mapk('t', '<C-k>', '<C-\\><C-N><C-w>k', opts)
  mapk('t', '<C-l>', '<C-\\><C-N><C-w>l', opts)
  mapk('i', '<C-h>', '<C-\\><C-N><C-w>h', opts)
  mapk('i', '<C-j>', '<C-\\><C-N><C-w>j', opts)
  mapk('i', '<C-k>', '<C-\\><C-N><C-w>k', opts)
  mapk('i', '<C-l>', '<C-\\><C-N><C-w>l', opts)
  mapk('t', '<Esc>', '<C-\\><C-N>', opts)

  -- TAB in general mode will move to text buffer, SHIFT-TAB will go back
  mapk('n', '<TAB>', ':bnext<CR>', opts)
  mapk('n', '<S-TAB>', ':bprevious<CR>', opts)

  -- Alternate way to save
  mapk('n', '<C-s>', ':w<CR>', opts)

  -- Alternate way to quit
  mapk('n', '<C-Q>', ':wq!<CR>', opts)
  mapk('n', '<Leader>x', ':q<CR>', opts)
  mapk('n', '<C-z>', ':undo<CR>', opts)

  -- Use control-c instead of escape
  mapk('n', '<C-c>', '<Esc>', opts)

  -- <TAB>: completion.
  mapk('i', '<expr><TAB>', 'pumvisible() ? "\\<C-n>" : "\\<TAB>"', opts)

  -- Better tabbing
  mapk('v', '<', '<gv', opts)
  mapk('v', '>', '>gv', opts)

  -- Greatest remap ever
  mapk('v', '<Leader>p', '"_dP', opts)

  -- next greatest remap ever : asbjornHaland
  mapk('n', '<Leader>y', '"+y', opts)
  mapk('v', '<Leader>y', '"+y', opts)
  mapk('n', '<Leader>Y', 'gg"+yG', opts)
  mapk('n', '<Leader>V', 'gg"+VG', opts)
  mapk('n', '<Leader>D', 'gg"+VGd', opts)

  -- Other remaps
  mapk('x', 'J', ":m '>+1<CR>gv=gv", opts)
  mapk('v', 'K', ":m '<-2<CR>gv=gv", opts)
  mapk('x', 'N', ":m '>+1<CR>gv=gv", opts)

  -- Source init.vim
  mapk('n', '<Leader><CR>', ':so ~/.config/nvim/init.vim<CR>', opts)
  mapk('n', '<Leader>.', ':e $MYVIMRC<CR>', opts)
  mapk('n', '<Leader>,', ':e ~/.config/nvim/lua/init.lua<CR>', opts)
end

