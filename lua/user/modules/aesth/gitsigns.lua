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
      watch_index = { interval = 1000 },
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil, -- Use default
      use_decoration_api = false,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
        map("n", "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

        -- Actions
        map({ "n", "v" }, "<leader>hs", gs.stage_hunk)
        map({ "n", "v" }, "<leader>hr", gs.reset_hunk)
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function()
          gs.blame_line { full = true }
        end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function()
          gs.diffthis "~"
        end)
        map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    },
  }

  gitsigns.setup(rvim.gitsigns.setup)
end
