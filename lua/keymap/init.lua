local mp = require('keymap.map')
local nmap, vmap, xmap, imap, smap, nnoremap, inoremap = mp.nmap, mp.vmap,
                                                         mp.xmap, mp.imap,
                                                         mp.smap, mp.nnoremap,
                                                         mp.inoremap
local npairs = require('nvim-autopairs')
local opts = {expr = true}

_G.completion_confirm = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("")
    else
      vim.fn.nvim_select_popupmenu_item(0, false, false, {})
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-n>")
    end
  else
    return npairs.check_break_line_char()
  end
end

_G.tab = function()
  if vim.fn.pumvisible() ~= 0 then
    return npairs.esc("<C-n>")
  else
    if vim.fn["vsnip#available"](1) ~= 0 then
      vim.fn.feedkeys(string.format('%c%c%c(vsnip-expand-or-jump)', 0x80, 253,
                                    83))
      return npairs.esc("")
    else
      return npairs.esc("<Tab>")
    end
  end
end

_G.s_tab = function()
  if vim.fn.pumvisible() ~= 0 then
    return npairs.esc("<C-p>")
  else
    if vim.fn["vsnip#jumpable"](-1) ~= 0 then
      vim.fn.feedkeys(string.format('%c%c%c(vsnip-jump-prev)', 0x80, 253, 83))
      return npairs.esc("")
    else
      return npairs.esc("<C-h>")
    end
  end
end

-- Vista
nnoremap('<Leader>vv', ':Vista!!<CR>')

-- Lsp
nnoremap('<Leader>lf', ':LspFormatting<CR>')
nnoremap('<Leader>li', ':LspInfo<CR>')
nnoremap('<Leader>ll', ':LspLog<CR>')
nnoremap('<Leader>lr', ':LspRestart<CR>')
nnoremap('<Leader>lv', ':LspToggleVirtualText<CR>')
nnoremap('<Leader>lx', ':cclose<CR>')

-- Undo tree
nnoremap("<Leader>au", ":UndotreeToggle<CR>")

-- TS
nnoremap('<Leader>Ie', ':TSInstallInfo<CR>')

-- rnvimr
nnoremap('<Leader>ar', ':RnvimrToggle<CR>')

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
imap('<C-y>', "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-space>'", opts)
smap('<C-y>', "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-space>'", opts)

-- Compe
imap("<C-l>", "v:lua.completion_confirm()", opts)
inoremap("<C-Space>", "compe#complete()", opts)
inoremap("<CR> ", "compe#confirm('<CR>')", opts)
inoremap("<C-e>", "compe#close('<C-e>')", opts)
inoremap("<C-f>", "compe#scroll({ 'delta': +4 })", opts)
inoremap("<C-d>", "compe#scroll({ 'delta': -4 })", opts)

-- Tree
nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

-- Far
nnoremap("<Leader>Ff", ":Farr --source=vimgrep<CR>")
nnoremap("<Leader>Fr", ":Farr --source=rgnvim<CR>")
nnoremap("<Leader>FD", ":Fardo<CR>")

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
nnoremap("<Leader>gi", ":Git init<CR>")
nnoremap("<Leader>gk", ":diffget //2<CR>")
nnoremap("<Leader>gl", ":Git log<CR>")
nnoremap("<Leader>ge", ":Git push<CR>")
nnoremap("<Leader>gp", ":Git poosh<CR>")
nnoremap("<Leader>gP", ":Git pull<CR>")
nnoremap("<Leader>gr", ":GRemove<CR>")
nnoremap("<Leader>gs", ":G<CR>")

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
nnoremap('<Leader>frc', ':Telescope dotfiles path=' .. os.getenv("HOME") ..
             '/.config/nvim' .. '<CR>')
-- Commands
nnoremap('<Leader>fce', ':lua require"telescope.builtin".planets{}<CR>')
nnoremap('<Leader>fcA', ':lua require("telescope.builtin").autocommands()<CR>')
nnoremap('<Leader>fcb', ':lua require("telescope.builtin").buffers()<CR>')
nnoremap('<Leader>fcc', ':lua require("telescope.builtin").commands()<CR>')
nnoremap('<Leader>fcf', ':lua require("telescope.builtin").builtin()<CR>')
nnoremap('<Leader>fch', ':lua require("telescope.builtin").help_tags()<CR>')
nnoremap('<Leader>fcH',
         ':lua require("telescope.builtin").command_history()<CR>')
nnoremap('<Leader>fck', ':lua require("telescope.builtin").keymaps()<CR>')
nnoremap('<Leader>fcl', ':lua require("telescope.builtin").loclist()<CR>')
nnoremap('<Leader>fco', ':lua require("telescope.builtin").oldfiles()<CR>')
nnoremap('<Leader>fcr', ':lua require("telescope.builtin").registers()<CR>')
nnoremap('<Leader>fcT', ':lua require("telescope.builtin").treesitter()<CR>')
nnoremap('<Leader>fcv', ':lua require("telescope.builtin").vim_options()<CR>')
nnoremap('<Leader>fcz',
         ':lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>')
-- Lsp
nnoremap('<Leader>fva',
         ':lua require("telescope.builtin").lsp_code_action()<CR>')
nnoremap('<Leader>fvr', ':lua require("telescope.builtin").lsp_references()<CR>')
nnoremap('<Leader>fvsd',
         ':lua require("telescope.builtin").lsp_document_symbols()<CR>')
nnoremap('<Leader>fvsw',
         ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>')
-- Live
nnoremap('<Leader>flg', ':lua require("telescope.builtin").live_grep()<CR>')
nnoremap('<Leader>flw',
         ':lua require("telescope.builtin").grep_string { search = vim.fn.expand("<cword>") }<CR>')
nnoremap('<Leader>fle',
         ':lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ")})<CR>')
-- Git
nnoremap('<Leader>fgb', ':lua require("telescope.builtin").git_branches()<CR>')
nnoremap('<Leader>fgc', ':lua require("telescope.builtin").git_commits()<CR>')
nnoremap('<Leader>fgC', ':lua require("telescope.builtin").git_bcommits()<CR>')
nnoremap('<Leader>fgf', ':lua require("telescope.builtin").git_files()<CR>')
nnoremap('<Leader>fgs', ':lua require("telescope.builtin").git_status()<CR>')
-- Extensions
nnoremap('<leader>fee',
         ':lua require("telescope").extensions.packer.plugins()<CR>')
nnoremap('<Leader>fem',
         ':lua require("telescope").extensions.media_files.media_files()<CR>')
nnoremap('<Leader>feb',
         ':lua require("modules.completion.telescope.conf").anime_selector()<CR>')
