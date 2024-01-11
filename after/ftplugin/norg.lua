if not rvim or rvim.none then return end

if not rvim.plugins.enable then return end

rvim.ftplugin_conf({
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
