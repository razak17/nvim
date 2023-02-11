local filename = vim.fn.expand('%:t')
if filename ~= 'Cargo.toml' then return end

local ok, which_key = rvim.safe_require('which-key', { silent = true })
if ok then which_key.register({ ['<localleader>'] = { c = { name = 'Crates' } } }) end
local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end
local crates = require('crates')
nnoremap('<localleader>ct', crates.toggle, with_desc('crates: toggle'))
nnoremap('<localleader>cu', crates.update_crate, with_desc('crates: update'))
nnoremap('<localleader>cU', crates.upgrade_crate, with_desc('crates: upgrade'))
nnoremap('<localleader>ca', crates.update_all_crates, with_desc('crates: update all'))
nnoremap('<localleader>cA', crates.upgrade_all_crates, with_desc('crates: upgrade all'))
nnoremap('<localleader>ch', crates.open_homepage, with_desc('crates: open home'))
nnoremap('<localleader>cr', crates.open_repository, with_desc('crates: open repo'))
nnoremap('<localleader>cd', crates.open_documentation, with_desc('crates: open doc'))
nnoremap('<localleader>cc', crates.open_crates_io, with_desc('crates: open crates.io'))
nnoremap('<localleader>ci', crates.show_popup, with_desc('crates: info'))
nnoremap('<localleader>cv', crates.show_versions_popup, with_desc('crates: versions'))
nnoremap('<localleader>cf', crates.show_features_popup, with_desc('crates: features'))
nnoremap('<localleader>cD', crates.show_dependencies_popup, with_desc('crates: dependencies'))
