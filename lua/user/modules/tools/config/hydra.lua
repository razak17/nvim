return function()
  local Hydra = require("hydra")
  local border = rvim.style.border.current

  Hydra({
    name = "Side scroll",
    mode = "n",
    body = "z",
    heads = {
      { "h", "5zh" },
      { "l", "5zl", { desc = "←/→" } },
      { "H", "zH" },
      { "L", "zL", { desc = "half screen ←/→" } },
    },
  })

  Hydra({
    name = "Window management",
    config = {
      hint = {
        border = border,
      },
    },
    mode = "n",
    body = "<C-w>",
    heads = {
      -- Move
      { "h", "<C-w>h" },
      { "j", "<C-w>j" },
      { "k", "<C-w>k" },
      { "l", "<C-w>l" },
      -- Split
      { "s", "<C-w>s" },
      { "v", "<C-w>v" },
      { "q", "<Cmd>Bwipeout<CR>", { desc = "close window" } },
      -- Size
      { "+", "2<C-w>+" },
      { "-", "2<C-w>-" },
      { ">", "5<C-w>>", { desc = "increase width" } },
      { "<", "5<C-w><", { desc = "decrease width" } },
      { "=", "<C-w>=", { desc = "equalize" } },
      --
      { "<Esc>", nil, { exit = true } },
    },
  })
end
