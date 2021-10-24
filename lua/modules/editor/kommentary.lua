return function()
  require("kommentary.config").configure_language("default", { prefer_single_line_comments = true })
  local fts = { "zsh", "sh", "yaml", "vim" }
  for _, f in pairs(fts) do
    if f == "vim" then
      require("kommentary.config").configure_language(f, { single_line_comment_string = '"' })
    else
      require("kommentary.config").configure_language(f, { single_line_comment_string = "#" })
    end
  end
  -- Mappings
  rvim.vmap("<leader>/", "<Plug>kommentary_visual_default")
end


