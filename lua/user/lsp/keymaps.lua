local M = {}

function M.init(client, bufnr)
  if not client == nil then
    return
  end

  -- Remap using which_key
  local status_ok, wk = rvim.safe_require "which-key"
  if not status_ok then
    return
  end

  local maps = {
    n = {
      gl = {
        "<cmd>lua require 'user.utils.lsp'.show_line_diagnostics()<CR>",
        "lsp: line diagnostics",
      },
    },
    x = {},
  }
  -- TODO: all references to `resolved_capabilities.capability_name` will need to be changed to
  -- `server_capabilities.camelCaseCapabilityName`
  -- use client.supports_method for now
  -- https://github.com/neovim/neovim/issues/14090#issuecomment-1113956767

  if client.supports_method "textDocument/declaration" then
    maps.n["K"] = { vim.lsp.buf.hover, "lsp: hover" }
  end

  if client.supports_method "textDocument/definition" then
    maps.n["gd"] = { vim.lsp.buf.definition, "lsp: definition" }
  end

  if client.supports_method "textDocument/references" then
    maps.n["gr"] = { vim.lsp.buf.references, "lsp: references" }
  end

  if client.supports_method "textDocument/declaration" then
    maps.n["ge"] = { vim.lsp.buf.declaration, "lsp: declaration" }
  end

  if client.supports_method "textDocument/implementation" then
    maps.n["gi"] = { vim.lsp.buf.implementation, "lsp: implementation" }
  end

  if client.supports_method "textDocument/typeDefinition" then
    maps.n["gT"] = { vim.lsp.buf.type_definition, "lsp: go to type definition" }
  end

  if client.supports_method "callHierarchy/incomingCalls" then
    maps.n["gI"] = { vim.lsp.buf.incoming_calls, "lsp: incoming calls" }
  end

  ------------------------------------------------------------------------------
  -- leader keymaps
  ------------------------------------------------------------------------------

  maps.n["<leader>lj"] = {
    "<cmd>lua vim.diagnostic.goto_next()<cr>",
    "lsp: next diagnostic",
  }
  maps.n["<leader>lk"] = {
    "<cmd>lua vim.diagnostic.goto_prev()<cr>",
    "lsp: prev diagnostic",
  }
  maps.n["<leader>lL"] = {
    "<cmd>lua vim.diagnostic.setloclist()<cr>",
    "lsp: set loclist",
  }

  maps.n["<leader>lp"] = {
    name = "+Peek",
    d = {
      "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
      "peek: definition",
    },
    i = {
      "<cmd>lua require('user.lsp.peek').Peek('implementation')<cr>",
      "peek: implementation",
    },
    t = {
      "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
      "peek: type definition",
    },
  }

  -- if client.resolved_capabilities.formatting then
  if client.supports_method "textDocument/formatting" then
    maps.n["<leader>lf"] = {
      "<cmd>LspFormat<cr>",
      "lsp: format",
    }
  end

  if client.supports_method "textDocument/codeLens" then
    maps.n["<leader>lc"] = { "<cmd>lua vim.lsp.codelens.run()<cr>", "lsp: codelens action" }
  end

  for mode, value in pairs(maps) do
    wk.register(value, { buffer = bufnr, mode = mode })
  end
end

return M
