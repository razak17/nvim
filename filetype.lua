if not vim.filetype then
  return
end

vim.filetype.add({
  extension = {
    lock = 'yaml',
  },
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['go.mod'] = 'gomod',
    ['.gitignore'] = 'conf',
    ['launch.json'] = 'jsonc',
    ['Makefile.toml'] = 'cargo-make',
    ['Podfile'] = 'ruby',
    ['.vimrc.local'] = 'vim',
    ['rebar.config'] = 'erlang',
  },
  pattern = {
    ['.*%.sld'] = 'slide',
    ['.*%.graphql'] = 'graphql',
    ['.*%.gql'] = 'graphql',
    ['.*%.conf'] = 'conf',
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['.*%.bkp'] = 'haskell',
    ['.*%.csv'] = 'csv',
    ['.*%.dat'] = 'csv',
    ['.*%.tsv'] = 'csv',
    ['.*%.tab'] = 'csv',
    ['.*%.info'] = 'info',
    ['.*%.app'] = 'erlang',
    ['.*%.xrl'] = 'erlang',
    ['.*%.escript'] = 'erlang',
    ['.*%.yaws'] = 'erlang',
    ['.*%.env%..*'] = 'env',
    ['.*%.js.map'] = 'json',
    ['.*%.app.src'] = 'erlang',
    ['.*%.tmux%..conf'] = 'tmux',
    ['.*%.gitsendmail%..*'] = 'gitsendmail',
  },
})
