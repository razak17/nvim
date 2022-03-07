return function()
  local gitsigns_ok, gitsigns = rvim.safe_require "gitsigns"
  if not gitsigns_ok then
    return
  end

  rvim.gitsigns = {
    setup = {
      signs = {
        add = { hl = "GitGutterAdd", text = "▋" },
        change = { hl = "GitGutterChange", text = "▋" },
        delete = { hl = "GitGutterDelete", text = "▋" },
        topdelete = { hl = "GitGutterDeleteChange", text = "▔" },
        changedelete = { hl = "GitGutterChange", text = "▎" },
      },
      on_attach = function()
        require("which-key").register {
          ["<leader>h"] = {
            name = "+Gitsigns",
            j = { gitsigns.next_hunk(), "Next Hunk" },
            k = { gitsigns.prev_hunk(), "Prev Hunk" },
            s = { gitsigns.stage_hunk, "stage" },
            u = { gitsigns.undo_stage_hunk, "undo stage" },
            r = { gitsigns.reset_hunk, "reset hunk" },
            p = { gitsigns.preview_hunk, "preview hunk" },
            l = { gitsigns.blame_line, "blame line" },
            R = { gitsigns.reset_buffer, "reset buffer" },
            d = { gitsigns.toggle_word_diff, "toggle word diff" },
            w = { gitsigns.stage_buffer, "stage entire buffer" },
          },
        }
      end,
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil, -- Use default
    },
  }

  gitsigns.setup(rvim.gitsigns.setup)

  require("which-key").register {
    ["<leader>h"] = {
      name = "+Gitsigns",
      b = "blame line",
      e = "preview hunk",
      r = "reset hunk",
      s = "stage hunk",
      t = "toggle line blame",
      u = "undo stage hunk",
    },
  }
end
