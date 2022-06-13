local M = {}

local Log = require("user.core.log")
local utils = require("user.utils")
local ftplugin_dir = rvim.lsp.templates_dir
local fmt = string.format
local find_string = rvim.find_string

local function write_manager(filename, server_name)
  local cmd = fmt([[require("user.lsp.manager").setup(%q)]], server_name)
  utils.write_file(filename, cmd .. "\n", "a")
end

local function write_override(filename, server_name)
  local cmd = fmt([[require("user.lsp.manager").override_setup(%q)]], server_name)
  utils.write_file(filename, cmd .. "\n", "a")
end

local function write_ft(filename, filetype)
  local cmd = fmt([[require("user.utils.after_ftplugin").setup(%q)]], filetype)
  utils.write_file(filename, cmd .. "\n", "a")
end

function M.remove_template_files()
  -- remove any outdated files
  for _, file in ipairs(vim.fn.glob(ftplugin_dir .. "/*.lua", 1, 1)) do
    vim.fn.delete(file)
  end
end

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@param dir string the full path to the desired directory
function M.generate_ftplugin(server_name, dir)
  if vim.tbl_contains(rvim.lsp.override, server_name) then
    return
  end

  -- we need to go through lspconfig to get the corresponding filetypes currently
  local filetypes = require("user.utils.lsp").get_supported_filetypes(server_name) or {}
  if not filetypes then
    return
  end

  for _, filetype in ipairs(filetypes) do
    local filename = join_paths(dir, filetype .. ".lua")

    -- lsp config for other servers
    if not find_string(rvim.lsp.override_ft, filetype) then
      write_manager(filename, server_name)
    end

    if server_name == "vuels" then
      write_manager(filename, "eslint")
    end

    if find_string(rvim.lsp.emmet_ft, filetype) then
      write_override(filename, "emmet_ls")
    end

    if vim.tbl_contains(rvim.lsp.override_servers, server_name) then
      write_override(filename, server_name)
    end

    -- ftplugin settings
    if find_string(rvim.util.ftplugin_filetypes, filetype) then
      -- TEMPFIX: Prevent after_ftplugin for js from generating twice
      if server_name == "quick_lint_js" then
        return
      end

      if filetype == "typescript.tsx" then
        write_ft(filename, "typescriptreact")
      elseif filetype == "javascript.jsx" then
        write_ft(filename, "javascriptreact")
      else
        write_ft(filename, filetype)
      end
    end
  end
end

---Generates ftplugin files based on a list of server_names
---The files are generated to a runtimepath: "$LUNARVIM_RUNTIME_DIR/site/after/ftplugin/template.lua"
---@param servers_names table list of servers to be enabled. Will add all by default
function M.generate_templates(servers_names)
  servers_names = servers_names or {}

  Log:debug("Templates installation in progress")

  M.remove_template_files()

  if vim.tbl_isempty(servers_names) then
    -- local available_servers = require("nvim-lsp-installer.servers").get_available_servers()
    local available_servers = require("nvim-lsp-installer.servers").get_installed_servers()

    for _, server in pairs(available_servers) do
      table.insert(servers_names, server.name)
      table.sort(servers_names)
    end
  end

  -- create the directory if it didn't exist
  if not utils.is_directory(rvim.lsp.templates_dir) then
    vim.fn.mkdir(ftplugin_dir, "p")
  end

  for _, server in ipairs(servers_names) do
    M.generate_ftplugin(server, ftplugin_dir)
  end

  -- Custom lsp config
  local custom_lsp = {
    markdown = "marksman",
  }

  for ft, server in pairs(custom_lsp) do
    local filename = join_paths(ftplugin_dir, ft .. ".lua")
    write_manager(filename, server)
  end
  Log:debug("Templates installation is complete")
end

return M
