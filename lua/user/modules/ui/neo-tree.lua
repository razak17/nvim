return function()
  require("zephyr.util").plugin(
    "NeoTree",
    { "NeoTreeIndentMarker", { link = "Comment" } },
    { "NeoTreeNormal", { link = "PanelBackground" } },
    { "NeoTreeNormalNC", { link = "PanelBackground" } },
    { "NeoTreeRootName", { bold = true, italic = false, foreground = rvim.palette.base6 } }
  )
  vim.g.neo_tree_remove_legacy_commands = 1
  local icons = rvim.style.icons
  rvim.nnoremap("<c-n>", "<Cmd>Neotree toggle reveal<CR>")
  require("which-key").register {
    ["<leader>e"] = { "<Cmd>Neotree toggle reveal<CR>", "toggle tree" },
  }
  require("neo-tree").setup {
    enable_git_status = true,
    git_status_async = true,
    filesystem = {
      netrw_hijack_behavior = "open_current",
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    default_component_configs = {
      git_status = {
        symbols = {
          added = icons.git.add,
          deleted = icons.git.remove,
          modified = icons.git.mod,
          renamed = icons.git.rename,
          untracked = "",
          ignored = "",
          unstaged = "",
          staged = "",
          conflict = "",
        },
      },
    },
    window = {
      position = "right",
      width = 40,
      mappings = {
        o = "toggle_node",
      },
    },
  }
end
