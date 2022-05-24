return function()
  require("zephyr.util").plugin("NeoTree", {
    NeoTreeIndentMarker = { link = "Comment" },
    NeoTreeNormal = { link = "PanelBackground" },
    NeoTreeNormalNC = { link = "PanelBackground" },
    NeoTreeRootName = { bold = true, italic = false, foreground = rvim.palette.base6 },
    NeoTreeCursorLine = { link = "Visual" },
  })
  vim.g.neo_tree_remove_legacy_commands = 1
  local icons = rvim.style.icons
  rvim.nnoremap("<c-n>", "<Cmd>Neotree toggle reveal<CR>")
  require("which-key").register({
    ["<leader>e"] = { "<Cmd>Neotree toggle reveal<CR>", "toggle tree" },
  })
  require("neo-tree").setup({
    enable_git_status = true,
    git_status_async = true,
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.cmd("setlocal signcolumn=no")
          vim.cmd("highlight! Cursor blend=100")
        end,
      },
      {
        event = "neo_tree_buffer_leave",
        handler = function()
          vim.cmd("highlight! Cursor blend=0")
        end,
      },
    },
    filesystem = {
      hijack_netrw_behavior = "open_current",
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = {
          ".DS_Store",
        },
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
      width = 30,
      mappings = {
        o = "toggle_node",
        h = "open",
        l = "open",
        ["<CR>"] = "open_with_window_picker",
        ["<c-s>"] = "split_with_window_picker",
        ["<c-v>"] = "vsplit_with_window_picker",
      },
    },
  })
end
