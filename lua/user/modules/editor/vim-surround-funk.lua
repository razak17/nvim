return function()
  vim.g.surround_funk_create_mappings = 0
  local map = vim.keymap.set
  -- operator pending mode: grip surround
  map({ "n", "v" }, "gs", "<Plug>(GripSurroundObject)")
  map({ "o", "x" }, "sF", "<Plug>(SelectWholeFUNCTION)")
  require("which-key").register {
    ["<leader>r"] = {
      name = "+dsf: delete",
      s = {
        F = { "<Plug>(DeleteSurroundingFunction)", "delete surrounding function" },
        f = { "<Plug>(DeleteSurroundingFUNCTION)", "delete surrounding outer function" },
      },
    },
    ["<leader>C"] = {
      name = "+dsf: change",
      s = {
        F = { "<Plug>(ChangeSurroundingFunction)", "change surrounding function" },
        f = { "<Plug>(ChangeSurroundingFUNCTION)", "change outer surrounding function" },
      },
    },
  }
end
