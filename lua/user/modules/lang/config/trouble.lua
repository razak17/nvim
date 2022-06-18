local M = {}

function M.setup()
  rvim.nnoremap("<leader>lz", "<cmd>TroubleToggle workspace_diagnostics<CR>", "trouble: toggle")
  rvim.nnoremap("<leader>ly", "<cmd>TroubleToggle lsp_references<CR>", "trouble: lsp references")
  -- ["<leader>lq"] = { ":TroubleToggle quickfix<cr>", "trouble: toggle quickfix" },
  -- ["<leader>ll"] = { ":TroubleToggle loclist<cr>", "trouble: toggle loclist" },
end

function M.config()
  local trouble = require("trouble")
  rvim.nnoremap("]d", function()
    trouble.previous({ skip_groups = true, jump = true })
  end, "trouble: previous item")
  rvim.nnoremap("[d", function()
    trouble.next({ skip_groups = true, jump = true })
  end, "trouble: next item")
  trouble.setup({ auto_close = true, auto_preview = false })
end

return M
