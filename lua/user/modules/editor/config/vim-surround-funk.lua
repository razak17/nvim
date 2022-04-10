return function()
  vim.g.surround_funk_create_mappings = 0
  local map = vim.keymap.set
  -- operator pending mode: grip surround
  map({ "n", "v" }, "gs", "<Plug>(GripSurroundObject)")
  map({ "o", "x" }, "sF", "<Plug>(SelectWholeFUNCTION)")

  require("which-key").register {
    ["<leader>rf"] = { "<Plug>(DeleteSurroundingFunction)", "dsf: delete surrounding function" },
    ["<leader>rF"] = { "<Plug>(DeleteSurroundingFUNCTION)", "dsf: delete surrounding outer function" },
    ["<leader>Cf"] = { "<Plug>(ChangeSurroundingFunction)", "dsf: change surrounding function" },
    ["<leader>CF"] = { "<Plug>(ChangeSurroundingFUNCTION)", "dsf: change outer surrounding function" },
  }
end
