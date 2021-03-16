local config = {}

function config.far()
  local function conf( key, value)
    vim.g[key] = value
  end

  conf('far#source', 'rgnvim')
  conf('far#window_width', 50)

  -- Use %:p with buffer option only
  conf('far#file_mask_favorites', { '%:p', '**/*.*', '**/*.js', '**/*.py', '**/*.lua', '**/*.css', '**/*.ts', '**/*.vim', '**/*.cpp', '**/*.c', '**/*.h', })
  conf('far#window_min_content_width', 30)
  conf('far#enable_undo', 1)
end

function config.tagalong()
  vim.g.tagalong_filetypes = { 'html', 'xml', 'jsx', 'eruby', 'ejs', 'eco', 'php', 'htmldjango', 'javascriptreact', 'typescriptreact', 'javascript' }
  vim.g.tagalong_verbose = 1
end

return config


