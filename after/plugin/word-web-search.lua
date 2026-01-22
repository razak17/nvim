local enabled = ar.config.plugin.custom.word_web_search.enable

if not ar or ar.none or not enabled then return end

function ar.ddg_search(path)
  ar.web_search(path, 'https://html.duckduckgo.com/html?q=')
end

function ar.gh(path) ar.web_search(path, 'https://github.com/search?q=') end

-- Search DuckDuckGo
map(
  'n',
  '<localleader>?',
  [[:lua ar.ddg_search(vim.fn.expand("<cword>"))<CR>]],
  { desc = 'search word' }
)
map(
  'x',
  '<localleader>?',
  [["gy:lua ar.ddg_search(vim.api.nvim_eval("@g"))<CR>gv]],
  { desc = 'search word' }
)
-- Search Github
map(
  'n',
  '<localleader>!',
  [[:lua ar.gh_search(vim.fn.expand("<cword>"))<CR>]],
  { desc = 'gh search word' }
)
map(
  'x',
  '<localleader>!',
  [["gy:lua ar.gh_search(vim.api.nvim_eval("@g"))<CR>gv]],
  { desc = 'gh search word' }
)
