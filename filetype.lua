if not vim.filetype then return end

vim.filetype.add({
  extension = {
    lock = 'yaml',
    ['http'] = 'http',
  },
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    Spacefile = 'yaml',
    ['.env'] = 'config',
    ['.sequelizerc'] = 'javascript',
    ['.sqlfluff'] = 'toml',
    ['.sqruff'] = 'toml',
  },
  pattern = {
    -- ['.*%.blade%.php'] = 'php',
    ['.*%.razor'] = 'razor',
    ['.*%.theme'] = 'conf',
    ['.*%.service'] = 'systemd',
    ['.*%.gradle'] = 'groovy',
    ['.*%.env%..*'] = 'config',
    ['req.*.txt'] = 'config',
  },
})
