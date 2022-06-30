return function()
  -- NOTE: the limit is half the max lines because this is the cursor theme so
  -- unless the cursor is at the top or bottom it realistically most often will
  -- only have half the screen available
  local function get_height(self, _, max_lines)
    local results = #self.finder.results
    local PADDING = 4 -- this represents the size of the telescope window
    local LIMIT = math.floor(max_lines / 2)
    return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
  end

  require("user.utils.highlights").plugin(
    "dressing",
    { FloatTitle = { inherit = "Visual", bold = true } }
  )
  require("dressing").setup({
    input = {
      winblend = 2,
      insert_only = false,
      border = rvim.style.border.line,
    },
    select = {
      get_config = function(opts)
        -- center the picker for treesitter prompts
        if opts.kind == "treesitter" then
          return {
            backend = "telescope",
            telescope = require("telescope.themes").get_dropdown({
              layout_config = { height = get_height },
            }),
          }
        end
      end,
      telescope = require("telescope.themes").get_cursor({
        layout_config = { height = get_height },
      }),
    },
  })
end
