if not rvim then return end

local nnoremap = rvim.nnoremap
local with_desc = function(desc) return { buffer = 0, desc = desc } end
if rvim.plugin_installed('crates.nvim') then
  nnoremap('<localleader>Kt', "<cmd>lua require('crates').toggle()<CR>", with_desc('Toggle Hints'))
  nnoremap('<localleader>Ku', "<cmd>lua require('crates').update_crate()<CR>", with_desc('Update'))
  nnoremap('<localleader>KU', "<cmd>lua require('crates').upgrade_crate()<CR>", with_desc('Upgrade'))
  nnoremap('<localleader>Ka', "<cmd>lua require('crates').update_all_crates()<CR>", with_desc('Update All'))
  nnoremap('<localleader>KA', "<cmd>lua require('crates').upgrade_all_crates()<CR>", with_desc('Upgrade All'))
  nnoremap('<localleader>Kh', "<cmd>lua require('crates').open_homepage()<CR>", with_desc('Open Home'))
  nnoremap('<localleader>Kr', "<cmd>lua require('crates').open_repository()<CR>", with_desc('Open Repo'))
  nnoremap('<localleader>Kd', "<cmd>lua require('crates').open_documentation()<CR>", with_desc('Open Doc'))
  nnoremap('<localleader>Kc', "<cmd>lua require('crates').open_crates_io()<CR>", with_desc('Open Crates.io'))
  nnoremap('<localleader>Ki', "<cmd>lua require('crates').show_popup()<CR>", 'Info')
  nnoremap('<localleader>Kv', "<cmd>lua require('crates').show_versions_popup()<CR>", with_desc('Versions'))
  nnoremap('<localleader>Kf', "<cmd>lua require('crates').show_features_popup()<CR>", with_desc('Features'))
  nnoremap('<localleader>KD', "<cmd>lua require('crates').show_dependencies_popup()<CR>", 'Dependencies')
end
