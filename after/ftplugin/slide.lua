if not rvim or rvim.none then return end

if not rvim.plugins.enable or rvim.plugins.minimal then return end

local fmt = string.format
local function with_desc(desc)
  return { buffer = 0, desc = fmt('slides: %s', desc) }
end

map('n', '<localleader>aa', '<Cmd>SlideAscii term<CR>', with_desc('ascii term'))
map(
  'n',
  '<localleader>aA',
  '<Cmd>SlideAscii bigascii12<CR>',
  with_desc('ascii bigascii12')
)
map(
  'n',
  '<localleader>ab',
  '<Cmd>SlideAscii bfraktur<CR>',
  with_desc('ascii bfraktur')
)
map(
  'n',
  '<localleader>ae',
  '<Cmd>SlideAscii emboss<CR>',
  with_desc('ascii emboss')
)
map(
  'n',
  '<localleader>aE',
  '<Cmd>SlideAscii emboss2<CR>',
  with_desc('ascii emboss2')
)
map(
  'n',
  '<localleader>al',
  '<Cmd>SlideAscii letter<CR>',
  with_desc('ascii letter')
)
map(
  'n',
  '<localleader>am',
  '<Cmd>SlideAscii bigmono12<CR>',
  with_desc('ascii bigmono12')
)
map(
  'n',
  '<localleader>aw',
  '<Cmd>SlideAscii wideterm<CR>',
  with_desc('ascii wideterm')
)

rvim.ftplugin_conf({
  cmp = function(cmp)
    cmp.setup.filetype('slide', {
      sources = {
        { name = 'dictionary', max_item_count = 10, group_index = 1 },
        { name = 'spell', group_index = 1 },
        { name = 'emoji', group_index = 1 },
        { name = 'buffer', group_index = 2 },
      },
    })
  end,
})
