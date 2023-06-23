if not vim.filetype then return end

vim.filetype.add({
  extension = { lock = 'yaml' },
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    ['.env'] = 'config',
  },
  pattern = {
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['^.env%..*'] = 'sh',
    ['req.*.txt'] = 'config',
  },
})
