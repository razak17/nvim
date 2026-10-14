if not ar.get_plugin_cond('nvim-pack-ui') then return end

ar.pack.add({
  src = 'https://codeberg.org/cryptomilk/nvim-pack-ui',
  dev = true,
  cmd = { 'Pack' },
  keys = {
    { '<localleader>L', '<cmd>Pack<cr>', desc = 'pack: ui' },
  },
})
