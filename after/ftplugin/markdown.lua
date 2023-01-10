-- no distractions in markdown files
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.spell = true

local args = { buffer = 0 }

vim.cmd([[
    iabbrev :tup: 👍
    iabbrev :tdo: 👎
    iabbrev :smi: 😊
    iabbrev :sad: 😔
  ]])

if not rvim then return end

rvim.onoremap('ih', [[:<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>]], args)
rvim.onoremap('ah', [[:<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>]], args)
rvim.onoremap('aa', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rg_vk0"<cr>]], args)
rvim.onoremap('ia', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>]], args)
rvim.onoremap('ia', [[:<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>]], args)

rvim.nmap('<localleader>p', '<Plug>MarkdownPreviewToggle', args)

rvim.ftplugin_conf(
  'cmp',
  function(cmp)
    cmp.setup.filetype('markdown', {
      sources = cmp.config.sources({
        { name = 'dictionary' },
        { name = 'spell' },
        { name = 'emoji' },
      }, {
        { name = 'buffer' },
      }),
    })
  end
)
