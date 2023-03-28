local M = {}

local uv, fmt = vim.loop, string.format
local ftplugin_dir = rvim.lsp.templates_dir
-- stylua: ignore
local configured_filetypes = {
  'astro', 'lua', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'python', 'go', 'rust', 'yaml',
  'vue', 'vim', 'json', 'jsonc', 'html', 'css', 'sh', 'zsh', 'markdown', 'graphql', 'sql', 'prisma', 'svelte',
}

---Write command to file
---@param filename string the filetype for praticular server
---@param server_name string can be any server supported by nvim-lsp-installer
local function write_manager(filename, server_name)
  local cmd = fmt([[require("user.lsp.manager").setup(%q)]], server_name)
  local text = fmt('%s\n', cmd)
  local data = type(text) == 'string' and text or vim.inspect(text)
  uv.fs_open(filename, 'a', 438, function(open_err, fd)
    assert(not open_err, open_err)
    uv.fs_write(fd, data, -1, function(write_err)
      assert(not write_err, write_err)
      uv.fs_close(fd, function(close_err) assert(not close_err, close_err) end)
    end)
  end)
end

---Get supported filetypes per server
---@param server_name string can be any server supported by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
local function get_supported_filetypes(server_name)
  local status_ok, lspconfig = rvim.require(fmt('lspconfig.server_configurations.%s', server_name), { silent = true })
  if not status_ok then return {} end
  local filetypes = lspconfig.default_config.filetypes or {}
  local config = require('user.servers')(server_name)
  -- override filetypes from lspconfig
  if config and config.filetypes then filetypes = config.filetypes end
  return vim.tbl_filter(function(ft) return vim.tbl_contains(configured_filetypes, ft) end, filetypes or {})
end

---Get supported servers per filetype
---@param filter { filetype: string | string[] }?: (optional) Used to filter the list of server names.
---@return string[] list of names of supported servers
local function get_supported_servers(filter)
  local _, supported_servers = pcall(function() return require('mason-lspconfig').get_available_servers(filter) end)
  return supported_servers or {}
end

---Remove Templates
function M.remove_template_files()
  for _, file in ipairs(vim.fn.glob(ftplugin_dir .. '/*.lua', 1, 1)) do
    vim.fn.delete(file)
  end
end

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@param dir string the full path to the desired directory
local function generate_ftplugin(server_name, dir)
  local filetypes = get_supported_filetypes(server_name)
  if not filetypes then return end
  for _, filetype in ipairs(filetypes) do
    filetype = filetype:match('%.([^.]*)$') or filetype
    local filename = join_paths(dir, fmt('%s.lua', filetype))
    write_manager(filename, server_name)
  end
end

---Generates ftplugin files based on a list of server_names
---The files are generated to a runtimepath: "$RVIM_RUNTIME_DIR/site/after/ftplugin/template.lua"
function M.generate_templates(servers_names)
  servers_names = servers_names or get_supported_servers()
  M.remove_template_files()
  if not rvim.is_directory(ftplugin_dir) then vim.fn.mkdir(ftplugin_dir, 'p') end
  for _, server in ipairs(servers_names) do
    local config = require('user.servers')(server)
    if config then generate_ftplugin(server, ftplugin_dir) end
  end
  vim.notify('Templates have been generated', 'info', { title = 'Lsp' })
end

return M
