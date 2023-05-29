local M = {}

local uv, fmt = vim.loop, string.format
local falsy, lsp_config_file = rvim.falsy, rvim.lsp.config_file

local function write(file, content)
  local data = type(content) == 'string' and content or vim.inspect(content)
  uv.fs_open(file, 'a', 438, function(open_err, fd)
    assert(not open_err, open_err)
    if not fd then return end
    uv.fs_write(fd, data, -1, function(write_err)
      assert(not write_err, write_err)
      uv.fs_close(fd, function(close_err) assert(not close_err, close_err) end)
    end)
  end)
end

local function get_supported_filetypes(server_name)
  local ok, lspconfig = pcall(require, fmt('lspconfig.server_configurations.%s', server_name))
  if not ok then return {} end
  return lspconfig.default_config.filetypes or {}
end

local function get_supported_servers(filter)
  local _, supported_servers = pcall(function() return require('mason-lspconfig').get_available_servers(filter) end)
  return supported_servers or {}
end

function M.remove_template_files() vim.fn.delete(lsp_config_file) end

local function generate(server_names)
  table.sort(server_names, function(a, b) return a < b end)
  local servers_config = {}
  for _, server in ipairs(server_names) do
    if rvim.find_string(rvim.lsp.disabled, server) then goto continue end
    local config = require('user.servers')(server)
    local fts = get_supported_filetypes(server)
    if config and not falsy(fts) then servers_config[server] = fts end
    ::continue::
  end
  return servers_config
end

local function write_file(filename, data)
  vim.defer_fn(function() write(filename, data) end, 100)
end

---Generates lsp setup file based on a list of server_names
---The file is generated to a runtimepath: "~/.config/nvim/after/plugin/lspsetup.lua"
function M.generate_config_file(server_names)
  server_names = server_names or get_supported_servers()
  local servers_config = generate(server_names)
  if falsy(server_names) or falsy(servers_config) then
    vim.notify('No servers found', vim.log.levels.ERROR, { title = 'Lsp' })
    return
  end
  write_file(lsp_config_file, fmt('%s\n', 'if not rvim or rvim.minimal then return end'))
  write_file(lsp_config_file, fmt('%s', 'rvim.lspconfig('))
  write_file(lsp_config_file, servers_config)
  write_file(lsp_config_file, ')')
  vim.notify('Config file has been generated.\nRestart neovim to start using lsp.', 'info', { title = 'Lsp' })
end

return M
