local config = {}

-- Debug
function config.dap_install()
  vim.cmd [[packadd nvim-dap]]
  local dI = require "dap-install"
  dI.setup { installation_path = vim.g.dap_install_dir }
end

function config.nvim_lsp_settings()
  local lsp_settings_status_ok, lsp_settings = pcall(require, "nlspsettings")
  if lsp_settings_status_ok then
    lsp_settings.setup {
      config_home = vim.g.vim_path .. "/external/nlsp-settings",
    }
  end
end

function config.null_ls()
  local null_status_ok, null_ls = pcall(require, "null-ls")
  if null_status_ok then
    null_ls.config {}
    require("lspconfig")["null-ls"].setup {}
  end
end

function config.formatter()
  rvim.augroup("AutoFormat", { { events = { "BufWritePost" }, targets = { "*" }, command = ":silent FormatWrite" } })
end

function config.nvim_lint()
  rvim.augroup("AutoLint", {
    {
      events = { "BufWritePost" },
      targets = { "<buffer>" },
      command = ":silent lua require('lint').try_lint()",
    },
    {
      events = { "BufEnter" },
      targets = { "<buffer>" },
      command = ":silent lua require('lint').try_lint()",
    },
  })
end

function config.bqf()
  require("bqf").setup {
    preview = { border_chars = { "│", "│", "─", "─", "┌", "┐", "└", "┘", "█" } },
  }
end

function config.lightbulb()
  rvim.augroup("NvimLightbulb", {
    {
      events = { "CursorHold", "CursorHoldI" },
      targets = { "*" },
      command = function()
        require("nvim-lightbulb").update_lightbulb {
          sign = { enabled = false },
          virtual_text = { enabled = true },
        }
      end,
    },
  })
end

function config.lspsaga()
  vim.cmd [[packadd lspsaga.nvim]]
  local saga = require "lspsaga"
  saga.init_lsp_saga {
    use_saga_diagnostic_sign = false,
    code_action_icon = "💡",
    code_action_prompt = { enable = false, sign = false, virtual_text = false },
  }
  local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
  nnoremap("gd", ":Lspsaga lsp_finder<CR>")
  nnoremap("gsh", ":Lspsaga signature_help<CR>")
  nnoremap("gh", ":Lspsaga preview_definition<CR>")
  nnoremap("grr", ":Lspsaga rename<CR>")
  nnoremap("K", ":Lspsaga hover_doc<CR>")
  nnoremap("<Leader>va", ":Lspsaga code_action<CR>")
  vnoremap("<Leader>vA", ":Lspsaga range_code_action<CR>")
  nnoremap("<Leader>vdb", ":Lspsaga diagnostic_jump_prev<CR>")
  nnoremap("<Leader>vdn", ":Lspsaga diagnostic_jump_next<CR>")
  nnoremap("<Leader>vdl", ":Lspsaga show_line_diagnostics<CR>")
end

return config
