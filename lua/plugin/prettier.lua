local vim = vim
local g = vim.g
local opts = {noremap = true, silent = true}
local mapk = vim.api.nvim_set_keymap

g['autoformat'] = 1
g['autoformat_require_pragma'] = 0
g['config#single_quote']= 'true'
g['config#trailing_comma'] = 'all'
g['quickfix_enabled'] = 0
g['quickfix_auto_focus'] = 0
-- let g:prettier#config#parser = ''
-- let g:prettier#exec_cmd_async = 1
-- let g:prettier#config#print_width = 'auto'
-- let g:prettier#partial_format=1

-- autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

mapk('n', '<Leader>vy', '<Plug>(Prettier)', opts)
mapk('n', '<Leader>vy', ':Prettier<CR>', opts)




