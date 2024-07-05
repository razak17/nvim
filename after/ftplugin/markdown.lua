if not ar or ar.none then return end

local cmd = vim.cmd

vim.opt.spell = true
vim.b.formatting_disabled =
  not vim.startswith(vim.fn.expand('%'), vim.g.projects_dir)

cmd.iabbrev(':tup:', '👍')
cmd.iabbrev(':tdo:', '👎')
cmd.iabbrev(':smi:', '😊')
cmd.iabbrev(':sad:', '😔')

if not ar.plugins.enable or ar.plugins.minimal then return end

map(
  'n',
  '<localleader>Pm',
  '<Cmd>Glow<CR>',
  { desc = 'markdown preview', buffer = 0 }
)

map(
  'n',
  '<localleader>Pi',
  '<Cmd>PasteImage<CR>',
  { desc = 'paste clipboard image', buffer = 0 }
)

ar.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('markdown', {
      sources = {
        { name = 'dictionary', max_item_count = 10, group_index = 1 },
        { name = 'spell', group_index = 1 },
        { name = 'emoji', group_index = 1 },
        { name = 'buffer', group_index = 2 },
      },
    })
  end,
})
