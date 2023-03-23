if not rvim then return end

local opt = vim.opt_local

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

vim.cmd([[
  iabbrev :tup: 👍
  iabbrev :tdo: 👎
  iabbrev :smi: 😊
  iabbrev :sad: 😔
]])

local args = { buffer = 0, silent = true }
map('n', 'ih', [[:<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>]], args)
map('n', 'ah', [[:<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>]], args)
map('n', 'aa', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rg_vk0"<cr>]], args)
map('n', 'ia', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>]], args)
map('n', 'ia', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>]], args)

map('n', '<localleader>p', '<Plug>MarkdownPreviewToggle', args)

rvim.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('markdown', {
      sources = cmp.config.sources({
        -- { name = 'dictionary' },
        { name = 'spell' },
        { name = 'emoji' },
      }, {
        { name = 'buffer' },
      }),
    })
  end,
})
