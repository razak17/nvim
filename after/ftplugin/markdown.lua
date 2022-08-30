-- no distractions in markdown files
vim.wo.number = false
vim.wo.relativenumber = false

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

if rvim.plugin_loaded('markdown-preview.nvim') then
  rvim.nmap('<localleader>p', '<Plug>MarkdownPreviewToggle', args)
end

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

rvim.ftplugin_conf('nvim-surround', function(surround)
  surround.buffer_setup({
    surrounds = {
      l = {
        add = function()
          return {
            { '[' },
            { '](' .. vim.fn.getreg('*') .. ')' },
          }
        end,
      },
    },
  })
end)
