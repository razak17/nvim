if not ar or ar.none then return end

if not ar.plugins.enable then return end

ar.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('norg', {
      sources = {
        { name = 'dictionary', max_item_count = 10, group_index = 1 },
        { name = 'spell', group_index = 1 },
        { name = 'emoji', group_index = 1 },
        { name = 'dynamic', group_index = 1 },
        { name = 'buffer', group_index = 2 },
      },
    })
  end,
})
