-- Run in a clean child Neovim, without sourcing the user's config or plugins.
local root = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
vim.opt.runtimepath:prepend(
  vim.fs.normalize(vim.fs.joinpath(root, '../../../..'))
)
local ok, result = pcall(function()
  local request = vim.json.decode(io.read('*a'))
  vim.o.packlockfile = request.packlockfile
  local updates = dofile(vim.fs.joinpath(root, 'ui', 'updates.lua'))
  updates.worker = true
  local summary = updates.check(request.entries)
  return { summary = summary, records = updates.records }
end)
io.write(vim.json.encode(ok and result or { error = tostring(result) }))
io.flush()
