return function()
  local status_ok, _ = pcall(require, "nvim-autopairs")
  if not status_ok then
    return
  end
  -- skip it, if you use another global object
  _G.MUtils = {}
  local npairs = require "nvim-autopairs"
  local Rule = require "nvim-autopairs.rule"

  vim.g.completion_confirm_key = ""
  MUtils.completion_confirm = function()
    if vim.fn.pumvisible() ~= 0 then
      if vim.fn.complete_info()["selected"] ~= -1 then
        return vim.fn["compe#confirm"](npairs.esc "<cr>")
      else
        return npairs.esc "<cr>"
      end
    else
      return npairs.autopairs_cr()
    end
  end

  vim.cmd [[packadd nvim-compe]]
  if package.loaded["compe"] then
    require("nvim-autopairs.completion.compe").setup {
      map_cr = true, --  map <CR> on insert mode
      map_complete = true, -- it will auto insert `(` after select function or method item
    }
  end

  npairs.setup {
    check_ts = true,
    ts_config = {
      lua = { "string" }, -- it will not add pair on that treesitter node
      javascript = { "template_string" },
      java = false, -- don't check treesitter on java
    },
  }

  local ts_conds = require "nvim-autopairs.ts-conds"

  -- press % => %% is only inside comment or string
  npairs.add_rules {
    Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node { "string", "comment" }),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node { "function" }),
  }

  require("nvim-autopairs").setup { disable_filetype = { "TelescopePrompt", "vim" } }
end
