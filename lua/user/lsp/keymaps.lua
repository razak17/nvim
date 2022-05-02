local M = {}

function M.init(client, bufnr)
  if not client then
    return
  end

  -- Remap using which_key
  local status_ok, wk = rvim.safe_require "which-key"
  if not status_ok then
    return
  end

  local maps = {
    n = {
      K = { vim.lsp.buf.hover, "lsp: hover" },
      gd = { vim.lsp.buf.definition, "lsp: definition" },
      gr = { vim.lsp.buf.references, "lsp: references" },
      gl = {
        "<cmd>lua require 'user.utils.lsp'.show_line_diagnostics()<CR>",
        "lsp: line diagnostics",
      },
    },
    x = {},
  }

  if client.resolved_capabilities.declaration then
    maps.n["ge"] = { vim.lsp.buf.declaration, "lsp: declaration" }
  end

  if client.resolved_capabilities.implementation then
    maps.n["gi"] = { vim.lsp.buf.implementation, "lsp: implementation" }
  end

  if client.resolved_capabilities.type_definition then
    maps.n["gT"] = { vim.lsp.buf.type_definition, "lsp: go to type definition" }
  end

  if client.resolved_capabilities.incoming_calls then
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

  if client.resolved_capabilities.formatting then
    maps.n["<leader>lf"] = {
      "<cmd>LspFormat<cr>",
      "lsp: format",
    }
  end

  if client.resolved_capabilities.rename then
    maps.n["<leader>lr"] = { vim.lsp.buf.rename, "lsp: rename" }
  end

  if client.resolved_capabilities.code_lens then
    maps.n["<leader>lc"] = { "<cmd>lua vim.lsp.codelens.run()<cr>", "lsp: codelens action" }
  end

  for mode, value in pairs(maps) do
    wk.register(value, { buffer = bufnr, mode = mode })
  end
end

return M
