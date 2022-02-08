local M = {}

function M.setup_keymaps(client, bufnr)
  -- Remap using which_key
  local status_ok, wk = rvim.safe_require "which-key"
  if not status_ok then
    return
  end

  local maps = {
    n = {
      ["K"] = { vim.lsp.buf.hover, "lsp: hover" },
      ["gd"] = { vim.lsp.buf.definition, "lsp: definition" },
      ["gr"] = { vim.lsp.buf.references, "lsp: references" },
      ["gl"] = {
        "<cmd>lua require'user.lsp.utils'.show_line_diagnostics()<CR>",
        "lsp: line diagnostics",
      },
    },
    x = {},
  }

  if client.resolved_capabilities.declaration then
    maps.n["ge"] = { vim.lsp.buf.declaration, "lsp: declaration" }
  end

  if client.resolved_capabilities.implementation then
    maps.n["gi"] = { vim.lsp.buf.implementation, "lsp: impementation" }
  end

  if client.resolved_capabilities.type_definition then
    maps.n["gT"] = { vim.lsp.buf.type_definition, "lsp: go to type definition" }
  end

  if client.supports_method "textDocument/prepareCallHierarchy" then
    maps.n["gI"] = { vim.lsp.buf.incoming_calls, "lsp: incoming calls" }
  end

  -- leader keymaps

  if client.supports_method "textDocument/rename" then
    local renamer = nil
    local renamer_ok = nil

    if rvim.plugin.renamer.active then
      renamer_ok, renamer = rvim.safe_require "renamer"
      if not renamer_ok then
        return
      end
    end

    local active = renamer_ok and rvim.plugin.renamer.active
    local rename = active and renamer.rename or vim.lsp.buf.rename

    maps.n["<leader>lr"] = { rename, "lsp: rename" }
  end

  maps.n["<leader>lp"] = {
    name = "+Peek",
    d = {
      "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
      "peek definition",
    },
    i = {
      "<cmd>lua require('user.lsp.peek').Peek('implementation')<cr>",
      "peek implementation",
    },
    t = {
      "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
      "peek type definition",
    },
  }

  if client.supports_method "textDocument/formatting" then
    maps.n["<leader>lf"] = {
      "<cmd>LspFormat<cr>",
      "format",
    }
  end

  if client.supports_method "textDocument/publishDiagnostics" then
    maps.n["<leader>lj"] = {
      "<cmd>lua vim.diagnostic.goto_next()<cr>",
      "next diagnostic",
    }
    maps.n["<leader>lk"] = {
      "<cmd>lua vim.diagnostic.goto_prev()<cr>",
      "prev diagnostic",
    }
    maps.n["<leader>ll"] = {
      "<cmd>lua vim.diagnostic.setloclist()<cr>",
      "set loclist",
    }
  end

  if client.supports_method "textDocument/codeAction" then
    maps.n["<leader>la"] = { "<cmd>lua vim.lsp.buf.code_action<cr>", "code action" }
    maps.x["<leader>la"] = {
      "<esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>",
      "range code action",
    }
  end

  if client.supports_method "textDocument/codeLens" then
    maps.n["<leader>lc"] = { "<cmd>lua vim.lsp.codelens.run()<cr>", "codelens action" }
  end

  for mode, value in pairs(maps) do
    wk.register(value, { buffer = bufnr, mode = mode })
  end
end

return M
