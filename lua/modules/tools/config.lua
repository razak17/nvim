local config = {}

function config.bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_sign = ''
end

return config
