vim.opt_local.spell = true
  vim.opt_local.spelloptions = 'camel'
  -- no distractions in markdown files
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false

  local args = { buffer = 0 }

  vim.cmd([[
    iabbrev :tup: 👍
    iabbrev :tdo: 👎
    iabbrev :smi: 😊
    iabbrev :sad: 😔
  ]])

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
      delimiters = {
        pairs = {
          ['l'] = function()
            return {
              '[',
              '](' .. vim.fn.getreg('*') .. ')',
            }
          end,
        },
      },
    })
  end)
