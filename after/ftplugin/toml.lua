local filename = vim.fn.expand('%:t')
if filename ~= 'Cargo.toml' then return end

require('which-key').register({ ['<localleader>'] = { c = { name = 'Crates' } } })
local with_desc = function(desc) return { buffer = 0, desc = desc } end
local crates = require('crates')
map('n', '<localleader>ct', crates.toggle, with_desc('crates: toggle'))
map('n', '<localleader>cu', crates.update_crate, with_desc('crates: update'))
map('n', '<localleader>cU', crates.upgrade_crate, with_desc('crates: upgrade'))
map('n', '<localleader>ca', crates.update_all_crates, with_desc('crates: update all'))
map('n', '<localleader>cA', crates.upgrade_all_crates, with_desc('crates: upgrade all'))
map('n', '<localleader>ch', crates.open_homepage, with_desc('crates: open home'))
map('n', '<localleader>cr', crates.open_repository, with_desc('crates: open repo'))
map('n', '<localleader>cd', crates.open_documentation, with_desc('crates: open doc'))
map('n', '<localleader>cc', crates.open_crates_io, with_desc('crates: open crates.io'))
map('n', '<localleader>ci', crates.show_popup, with_desc('crates: info'))
map('n', '<localleader>cv', crates.show_versions_popup, with_desc('crates: versions'))
map('n', '<localleader>cf', crates.show_features_popup, with_desc('crates: features'))
map('n', '<localleader>cD', crates.show_dependencies_popup, with_desc('crates: dependencies'))
