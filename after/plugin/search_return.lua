local enabled = ar_config.plugin.custom.search_return.enable

if not ar or ar.none or not enabled then return end

-- https://www.reddit.com/r/neovim/comments/1k27y0t/go_back_to_the_start_of_a_search_for_the_current/
-- All the ways to start a search, with a description
local mark_search_keys = {
  ['/'] = 'Search forward',
  ['?'] = 'Search backward',
  ['*'] = 'Search current word (forward)',
  ['#'] = 'Search current word (backward)',
  ['£'] = 'Search current word (backward)',
  ['g*'] = 'Search current word (forward, not whole word)',
  ['g#'] = 'Search current word (backward, not whole word)',
  ['g£'] = 'Search current word (backward, not whole word)',
}

-- Before starting the search, set a mark `s`
for key, desc in pairs(mark_search_keys) do
  map('n', key, 'ms' .. key, { desc = desc })
end

-- Clear search highlight when jumping back to beginning
map('n', '[S', function()
  vim.cmd('normal! `s')
  vim.cmd.nohlsearch()
end, { desc = 'return to start of search' })
