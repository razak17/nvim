local loaded = false

local function load()
  if loaded then return end

  local path = vim.fs.joinpath(vim.g.projects_dir, 'plugins', 'nvim-pack-ui')
  vim.opt.rtp:prepend(path)
  dofile(path .. '/plugin/pack-ui.lua')

  -- vim.pack.add(
  --   { 'https://codeberg.org/cryptomilk/nvim-pack-ui' },
  --   { confirm = false }
  -- )
  loaded = true
end

ar.pack.cmd('Pack', load)

map(
  'n',
  '<localleader>L',
  function() vim.cmd('Pack') end,
  { desc = 'pack: ui' }
)
