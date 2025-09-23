local minimal = ar.plugins.minimal

-- Gets a property at path
---@param tbl table the table to access
---@param path string the '.' separated path
---@return table|nil result the value at path or nil
local function get_at_path(tbl, path)
  if path == '' then return tbl end

  local segments = vim.split(path, '.', true)
  ---@type table[]|table
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == 'table' then
      ---@type table
      -- TODO: figure out the actual type of tbl
      result = result[segment]
    end
  end

  return result
end

return {
  {
    {
      'stevearc/aerial.nvim',
      cmd = { 'AerialToggle' },
      cond = not minimal and ar.ts_extra_enabled,
      init = function()
        ar.add_to_select_menu('toggle', { ['Toggle Aerial'] = 'AerialToggle' })
      end,
      opts = {
        lazy_load = false,
        backends = {
          ['_'] = { 'treesitter', 'lsp', 'markdown', 'man' },
          elixir = { 'treesitter' },
          typescript = { 'treesitter' },
          typescriptreact = { 'treesitter' },
        },
        filter_kind = false,
        icons = {
          Field = ' 󰙅 ',
          Type = '󰊄 ',
        },
        treesitter = {
          experimental_selection_range = true,
        },
        k = 2,
        post_parse_symbol = function(bufnr, item, ctx)
          if
            ctx.backend_name == 'treesitter'
            and (ctx.lang == 'typescript' or ctx.lang == 'tsx')
          then
            local value_node = (get_at_path(ctx.match, 'var_type') or {}).node
            -- don't want to display in-function items
            local cur_parent = value_node and value_node:parent()
            while cur_parent do
              if
                cur_parent:type() == 'arrow_function'
                or cur_parent:type() == 'function_declaration'
                or cur_parent:type() == 'method_definition'
              then
                return false
              end
              cur_parent = cur_parent:parent()
            end
          elseif
            ctx.backend_name == 'lsp'
            and ctx.symbol
            and ctx.symbol.location
            and string.match(ctx.symbol.location.uri, '%.graphql$')
          then
            -- for graphql it was easier to go with LSP. Use the symbol kind to keep only the toplevel queries/mutations
            return ctx.symbol.kind == 5
          elseif
            ctx.backend_name == 'treesitter'
            and ctx.lang == 'html'
            and vim.fn.expand('%:e') == 'ui'
          then
            -- in GTK UI files only display 'object' items (widgets), and display their
            -- class instead of the tag name (which is always 'object')
            if item.name == 'object' then
              local line = vim.api.nvim_buf_get_lines(
                bufnr,
                item.lnum - 1,
                item.lnum,
                false
              )[1]
              local _, _, class = string.find(line, [[class=.([^'"]+)]])
              item.name = class
              return true
            else
              return false
            end
          end
          return true
        end,
        get_highlight = function(symbol, _)
          if symbol.scope == 'private' then return 'AerialPrivate' end
        end,
      },
      config = function(_, opts)
        vim.api.nvim_set_hl(
          0,
          'AerialPrivate',
          { default = true, italic = true }
        )
        require('aerial').setup(opts)
        require('telescope').load_extension('aerial')
      end,
    },
    {
      'nvim-telescope/telescope.nvim',
      optional = true,
      keys = function(_, keys)
        if not minimal and ar.ts_extra_enabled and ar.has('aerial.nvim') then
          table.insert(keys or {}, {
            '<leader>fd',
            function() require('telescope').extensions.aerial.aerial({}) end,
            desc = 'aerial',
          })
        end
      end,
      opts = function(_, opts)
        return (not minimal and ar.ts_extra_enabled and ar.has('aerial.nvim'))
            and vim.g.telescope_add_extension({ 'aerial' }, opts)
          or opts
      end,
    },
  },
  {
    'SmiteshP/nvim-navbuddy',
    cond = not minimal,
    cmd = { 'Navbuddy' },
    lazy = false,
    keys = {
      { '<leader>nv', '<Cmd>Navbuddy<CR>', desc = 'navbuddy: toggle' },
    },
    dependencies = { 'SmiteshP/nvim-navic' },
    opts = { lsp = { auto_attach = true } },
  },
  {
    'razak17/hierarchy.nvim',
    init = function()
      ar.add_to_select_menu('lsp', {
        ['Function References'] = 'FuncReferences',
      })
    end,
    cond = ar.lsp.enable,
    opts = {},
  },
  {
    desc = 'Flexible and sleek fuzzy picker, LSP symbol navigator, and more. inspired by Zed.',
    'bassamsdata/namu.nvim',
    cond = ar.lsp.enable,
    cmd = { 'Namu' },
    -- stylua: ignore
    keys = function()
      local mappings = { { '<leader>ld', '<Cmd>Namu diagnostics<CR>', desc = 'namu: diagnostics' }, }
      if ar_config.lsp.symbols.enable and ar_config.lsp.symbols.variant == 'namu' then
        ar.list_insert(mappings, {
          { '<leader>lsd', '<Cmd>Namu symbols<CR>', desc = 'namu: document symbols' },
          { '<leader>lsw', '<Cmd>Namu workspace<CR>', desc = 'namu: workspace symbols' },
        })
      end
      return mappings
    end,
    opts = {
      namu_symbols = {
        enable = true,
        options = {}, -- here you can configure namu
      },
      ui_select = { enable = false }, -- vim.ui.select() wrapper
    },
  },
}
