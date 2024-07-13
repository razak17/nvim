if not ar or ar.none then return end

if not ar.plugins.enable or ar.plugins.minimal then return end

if vim.fn.expand('%:t') == 'Cargo.toml' then
  local fmt = string.format

  require('cmp').setup.buffer({ sources = { { name = 'crates' } } })

  local function with_desc(desc)
    return { buffer = 0, desc = fmt('crates: %s', desc) }
  end
  local crates = require('crates')

  map('n', '<leader><localleader>cK', crates.show_popup, with_desc('hover'))
  map('n', '<leader><localleader>ct', crates.toggle, with_desc('toggle'))
  map('n', '<leader><localleader>cu', crates.update_crate, with_desc('update'))
  map('n', '<leader><localleader>cU', crates.upgrade_crate, with_desc('upgrade'))
  map('n', '<leader><localleader>ca', crates.update_all_crates, with_desc('update all'))
  map(
    'n',
    '<leader><localleader>cA',
    crates.upgrade_all_crates,
    with_desc('upgrade all')
  )
  map('n', '<leader><localleader>ch', crates.open_homepage, with_desc('open home'))
  map('n', '<leader><localleader>cr', crates.open_repository, with_desc('open repo'))
  map('n', '<leader><localleader>cd', crates.open_documentation, with_desc('open doc'))
  map(
    'n',
    '<leader><localleader>cp',
    crates.open_crates_io,
    with_desc('open crates.io')
  )
  map('n', '<leader><localleader>ci', crates.show_popup, with_desc('info'))
  map('n', '<leader><localleader>cv', crates.show_versions_popup, with_desc('versions'))
  map('n', '<leader><localleader>cf', crates.show_features_popup, with_desc('features'))
  map(
    'n',
    '<leader><localleader>cD',
    crates.show_dependencies_popup,
    with_desc('dependencies')
  )
end
