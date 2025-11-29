local enabled = ar.config.plugin.custom.surf_plugins.enable
local has_lazy = ar.has('lazy.nvim')

if
  not ar
  or ar.none
  or not ar.plugins.enable
  or not enabled and not has_lazy
then
  return
end

local function surf_plugins()
  local items = vim
    .iter(require('lazy').plugins())
    :map(function(plugin) return { name = plugin.name, dir = plugin.dir } end)
    :totable()

  local select_opts = {
    prompt = 'Surf Plugins:',
    format_item = function(item) return item.name end,
  }

  vim.ui.select(items, select_opts, function(choice)
    if choice == nil then return end
    ar.pick.open('files', { cwd = choice.dir })
  end)
end

map('n', '<leader>fll', surf_plugins, { desc = 'surf plugins' })
