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
  },
  pattern = {
    ['.*%.graphql'] = 'graphql',
    ['.*%.gql'] = 'graphql',
    ['.*%.conf'] = 'conf',
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['.*%.env%..*'] = 'env',
  },
})
