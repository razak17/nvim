local M = {}

local uv, fmt = vim.loop, string.format
local lsp_setup_file = rvim.lsp.setup_file

local function write_file(filename, content)
  local data = type(content) == 'string' and content or vim.inspect(content)
  uv.fs_open(filename, 'a', 438, function(open_err, fd)
    assert(not open_err, open_err)
    uv.fs_write(fd, data, -1, function(write_err)
      assert(not write_err, write_err)
      uv.fs_close(fd, function(close_err) assert(not close_err, close_err) end)
    end)
  end)
end

local function get_supported_filetypes(server_name)
  local status_ok, lspconfig = rvim.pcall(require, fmt('lspconfig.server_configurations.%s', server_name))
  if not status_ok then return {} end
  return lspconfig.default_config.filetypes or {}
end

local function get_supported_servers(filter)
  local _, supported_servers = pcall(function() return require('mason-lspconfig').get_available_servers(filter) end)
  return supported_servers or {}
end

---Remove Templates
function M.remove_template_files() vim.fn.delete(lsp_setup_file) end

local function generate(server_names)
  table.sort(server_names, function(a, b) return a < b end)
  for _, server in ipairs(server_names) do
    local config = require('user.servers')(server)
    if config then
      local fts = get_supported_filetypes(server)
      local data = fmt('  %s = %s%s\n', server, vim.inspect(fts), ',')
      write_file(lsp_setup_file, data)
    end
  end
end

---Generates lsp setup file based on a list of server_names
---The file is generated to a runtimepath: "~/.config/nvim/after/plugin/lspsetup.lua"
function M.generate_setup_file(server_names)
  server_names = server_names or get_supported_servers()
  if vim.tbl_isempty(server_names) then
    vim.notify('No servers found', 'error', { title = 'Lsp' })
    return
  end
  write_file(lsp_setup_file, fmt('%s\n%s\n', '-- stylua: ignore', 'rvim.lsp_setup({'))
  generate(server_names)
  write_file(lsp_setup_file, '})')
  vim.notify('Setup file has been generated', 'info', { title = 'Lsp' })
  vim.notify('Restart neovim to start lsp', 'info', { title = 'Lsp' })
end

return M
