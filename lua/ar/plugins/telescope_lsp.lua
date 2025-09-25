return {
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    keys = function(_, keys)
      if not ar.lsp.enable or ar_config.picker.variant ~= 'telescope' then
        return keys
      end

      keys = keys or {}

      local mappings = {}

      ---@param opts? table
      ---@return function
      local function b(picker, opts)
        opts = opts or {}
        return function() require('telescope.builtin')[picker](opts) end
      end

        -- stylua: ignore
        if ar.lsp.enable then
          ar.list_insert(mappings, {
            { '<leader>le', b('diagnostics', { bufnr = 0 }), desc = 'telescope: buffer diagnostics', },
            { '<leader>lI', b('lsp_implementations'), desc = 'telescope: search implementation', },
            { '<leader>lr', b('lsp_references'), desc = 'telescope: show references', },
            { '<leader>lw', b('diagnostics'), desc = 'telescope: workspace diagnostics', },
            { '<leader>ly', b('lsp_type_definitions'), desc = 'telescope: type definitions' },
          })
          -- stylua: ignore
          if ar_config.lsp.symbols.enable and ar_config.lsp.symbols.variant == 'picker' then
            ar.list_insert(mappings, {
              { '<leader>lsd', b('lsp_document_symbols'), desc = 'telescope: document symbols', },
              { '<leader>lsl', b('lsp_dynamic_workspace_symbols'), desc = 'telescope: live workspace symbols' },
              { '<leader>lsw', b('lsp_workspace_symbols'), desc = 'telescope: workspace symbols', },
            })
          end
        end

      vim.iter(mappings):each(function(m) table.insert(keys, m) end)
      return keys
    end,
  },
}
