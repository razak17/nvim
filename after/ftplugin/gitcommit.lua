vim.opt_local.spell = true

if not rvim then return end

rvim.ftplugin_conf('cmp', function(cmp)
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'luasnip' },
      -- { name = 'dictionary' },
      { name = 'spell' },
      { name = 'emoji' },
      { name = 'buffer' },
    }),
  })
end)
