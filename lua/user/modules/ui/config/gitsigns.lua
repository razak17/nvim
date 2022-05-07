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
      _threaded_diff = true, -- NOTE: experimental but I'm curious
      word_diff = false,
      numhl = false,
      preview_config = {
        border = rvim.style.border.current,
      },
      on_attach = function()
        local gs = package.loaded.gitsigns

        local function qf_list_modified()
          gs.setqflist "all"
        end

        require("which-key").register {
          ["<leader>h"] = {
            name = "+Gitsigns",
            j = { gs.next_hunk, "Next Hunk" },
            k = { gs.prev_hunk, "Prev Hunk" },
            m = { qf_list_modified, "list modified in qf" },
            -- s = { gs.stage_hunk, "stage" },
            u = { gs.undo_stage_hunk, "undo stage" },
            -- r = { gs.reset_hunk, "reset hunk" },
            p = { gs.preview_hunk, "preview hunk" },
            l = { gs.blame_line, "blame line" },
            R = { gs.reset_buffer, "reset buffer" },
            d = { gs.toggle_word_diff, "toggle word diff" },
            w = { gs.stage_buffer, "stage entire buffer" },
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

  vim.keymap.set("v", "<leader>hs", function()
    gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
  end)
  vim.keymap.set("v", "<leader>hr", function()
    gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
  end)

  vim.keymap.set({ "n" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>")
  vim.keymap.set({ "n" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>")

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
