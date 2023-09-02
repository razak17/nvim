if
  not rvim
  or not rvim.lsp.enable
  or not rvim.plugins.enable
  or rvim.plugins.minimal
then
  return
end

if vim.fn.expand('%:t') == 'Cargo.toml' then
  local fmt = string.format

  if rvim.is_available('which-key.nvim') then
    require('which-key').register({ ['<localleader>c'] = { name = 'Crates' } })
  end
  require('cmp').setup.buffer({ sources = { { name = 'crates' } } })

  local function with_desc(desc)
    return { buffer = 0, desc = fmt('crates: %s', desc) }
  end
  local crates = require('crates')

  map('n', 'K', crates.show_popup, with_desc('hover'))
  map('n', '<localleader>ct', crates.toggle, with_desc('toggle'))
  map('n', '<localleader>cu', crates.update_crate, with_desc('update'))
  map('n', '<localleader>cU', crates.upgrade_crate, with_desc('upgrade'))
  map('n', '<localleader>ca', crates.update_all_crates, with_desc('update all'))
  map(
    'n',
    '<localleader>cA',
    crates.upgrade_all_crates,
    with_desc('upgrade all')
  )
  map('n', '<localleader>ch', crates.open_homepage, with_desc('open home'))
  map('n', '<localleader>cr', crates.open_repository, with_desc('open repo'))
  map('n', '<localleader>cd', crates.open_documentation, with_desc('open doc'))
  map(
    'n',
    '<localleader>cp',
    crates.open_crates_io,
    with_desc('open crates.io')
  )
  map('n', '<localleader>ci', crates.show_popup, with_desc('info'))
  map('n', '<localleader>cv', crates.show_versions_popup, with_desc('versions'))
  map('n', '<localleader>cf', crates.show_features_popup, with_desc('features'))
  map(
    'n',
    '<localleader>cD',
    crates.show_dependencies_popup,
    with_desc('dependencies')
  )
end
