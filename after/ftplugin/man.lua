-- Ref: https://www.reddit.com/r/neovim/comments/sb5m1f/weird_issue_when_using_nvim1_as_my_pager/

-- Do not output any backspaces, printing only the last character written to each column position.
vim.cmd([[ silent keepj keepp %s/\v(.)\b\ze\1?//ge ]])

-- Remove any ANSI escape sequences.
vim.cmd([[ silent keepj keepp %s/\v\e\[%(%(\d;)?\d{1,2})?[mK]//ge ]])

-- Move the cursor back to the top of the buffer.
--cmd( [[]])
