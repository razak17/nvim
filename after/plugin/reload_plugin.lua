local enabled = ar_config.plugin.custom.reload_plugin.enable
local has_lazy = ar.has('lazy.nvim')
local has_telescope = ar.has('telescope.nvim')
local ar_picker = ar_config.picker.variant

if
  not ar
  or ar.none
  or not ar.plugins.enable
  or not enabled and not has_lazy
then
  return
end

if ar_picker ~= 'telescope' then
  map('n', '<leader>oL', function()
    local items = vim
      .iter(require('lazy').plugins())
      :map(function(plugin) return { name = plugin.name } end)
      :totable()

    local select_opts = {
      prompt = 'Reload plugin:',
      format_item = function(item) return item.name end,
    }

    vim.ui.select(items, select_opts, function(choice)
      if choice == nil then return end
      require('lazy').reload({ plugins = { choice.name } })
    end)
  end, { desc = 'lazy: reload plugins' })
  return
end

if not has_telescope or ar_picker ~= 'telescope' then return end

---@class Plugin
---@field path string
---@field name string
---@field readme string|nil
---@field url string
---@field lazy boolean
---@field dev boolean
---@field icon string

map('n', '<leader>oL', function()
  local config = require('telescope.config').values
  local entry_display = require('telescope.pickers.entry_display')
  local finders = require('telescope.finders')
  local pickers = require('telescope.pickers')
  local previewers = require('telescope.previewers')
  local actions = require('telescope.actions')
  local actions_state = require('telescope.actions.state')

  --------------------------------------------------------------------------------
  -- These function arre adapted from telescope-lazy.nvim
  -- @see: https://github.com/razak17/telescope-lazy.nvim
  --------------------------------------------------------------------------------

  --- Finds the length of the longest plugin name.
  ---@param plugins table<Plugin>: A table with all the plugins.
  ---@return number: The length of the longest plugin name.
  local function max_plugin_name_length(plugins)
    local max_length = 0
    for _, plugin in ipairs(plugins) do
      max_length = math.max(max_length, #plugin.name)
    end
    return max_length
  end

  --- Creates an internal representation of a LazyPlugin.
  ---@param lazy_plugin any: An instance of a LazyPlugin.
  ---@return Plugin: An internal representation of the LazyPlugin as a Plugin.
  local function create_plugin_from_lazy(lazy_plugin)
    ---@type Plugin
    ---@diagnostic disable-next-line: missing-fields
    local plugin = {}

    plugin.name = lazy_plugin.name
    plugin.lazy = lazy_plugin.lazy
    plugin.icon = ''

    -- Use LazyPluginState `_` for determining whether the plugin is `dev` or not, instead of the `dev` field.
    -- This also accounts for plugins that use the `dir` option in their plugin specification.
    plugin.dev = lazy_plugin._.is_local

    return plugin
  end

  local function get_plugins()
    ---@type table<Plugin>
    local plugins = {}

    local lazy_config = require('lazy.core.config')
    for _, lazy_plugin in pairs(lazy_config.plugins) do
      local plugin = create_plugin_from_lazy(lazy_plugin)
      table.insert(plugins, plugin)
    end

    return plugins
  end

  local telescope_lazy_plugins = get_plugins()
  local opts = {
    show_icon = true,
  }

  local function displayer()
    local items = {
      { width = max_plugin_name_length(telescope_lazy_plugins) },
      { width = 7 },
      { width = 5 },
    }

    if opts.show_icon then table.insert(items, 1, { width = 2 }) end

    return entry_display.create({
      separator = ' ',
      items = items,
    })
  end

  local function make_display(entry)
    local display = {
      { entry.value.name },
      { entry.value.lazy and '(lazy)' or '(start)', 'Comment' },
      { entry.value.dev and '(dev)' or '', 'Comment' },
    }

    if opts.show_icon then
      table.insert(display, 1, { entry.value.icon, 'SpecialChar' })
    end

    return displayer()(display)
  end

  local function previewer()
    return previewers.new_buffer_previewer({
      title = '[ Readme ]',
      dyn_title = function(_, entry) return '[ ' .. entry.value.name .. ' ]' end,
      define_preview = function(self, entry, status)
        if not entry.value.readme then return end
        vim.api.nvim_set_option_value(
          'wrap',
          true,
          { win = status.preview_win }
        )
        config.buffer_previewer_maker(entry.value.readme, self.state.bufnr, {
          winid = self.state.winid,
        })
      end,
    })
  end

  local function finder()
    return finders.new_table({
      results = telescope_lazy_plugins,
      entry_maker = function(entry)
        return {
          value = entry,
          ordinal = entry.name,
          display = make_display,
        }
      end,
    })
  end

  local function get_selected_entry()
    local selected_entry = actions_state.get_selected_entry()
    if not selected_entry then
      vim.notify(
        'Please make a valid selection before performing the action.',
        vim.log.levels.WARN
      )
      return
    end
    return selected_entry.value
  end

  local function reload_plugin(prompt_bufnr)
    actions.select_default:replace(function()
      local selected_entry = get_selected_entry()
      if not selected_entry then return end

      if selected_entry.name then
        actions.close(prompt_bufnr)
        require('lazy').reload({ plugins = { selected_entry.name } })
      end
    end)
  end

  local function attach_mappings(prompt_bufnr, _)
    reload_plugin(prompt_bufnr)
    return true
  end

  pickers
    .new(opts, {
      prompt_title = 'Search plugin',
      results_title = 'Installed plugins',
      finder = finder(),
      sorter = config.file_sorter(opts),
      previewer = previewer(),
      attach_mappings = attach_mappings,
    })
    :find()
end, { desc = 'lazy: reload plugins' })
