local g = vim.g

local function conf( key, value)
  g[key] = value
end

conf('far#source', 'rgnvim')
-- conf('#source', 'vimgrep')
-- conf('#source', 'rg')
conf('far#window_width', 50)

-- Use %:p with buffer option only
conf('far#file_mask_favorites', { '%:p', '**/*.*', '**/*.js', '**/*.py', '**/*.lua', '**/*.css', '**/*.ts', '**/*.vim', '**/*.cpp', '**/*.c', '**/*.h', })
conf('far#window_min_content_width', 30)
conf('far#enable_undo', 1)

-- icon    mode                        toggle
-- [.*]    regex                       CTRL-X
-- [Aa]    case-sentive,               CTRL-A
-- [""]    word boundary               CTRL-W
-- [⬇ ]    replacement (substitution)  CTRL-S
--         quit |Farr| or |Farf|       <Esc>
