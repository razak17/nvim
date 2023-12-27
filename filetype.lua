if not vim.filetype then return end

vim.filetype.add({
  extension = { lock = 'yaml' },
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    Spacefile = 'yaml',
    ['.env'] = 'config',
  },
  pattern = {
    ['.*%.theme'] = 'conf',
    ['.*%.service'] = 'systemd',
    ['.*%.gradle'] = 'groovy',
    ['.*%.env%..*'] = 'config',
    ['req.*.txt'] = 'config',
  },
})
