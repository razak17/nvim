local g, uv, api, fn = vim.g, vim.loop, vim.api, vim.fn
local packer_compiled = g.data_dir .. "/site/packer_compiled.vim"
local install_path = g.data_dir .. "/site/pack/"
local compile_to_lua = g.data_dir .. "/site/lua/_compiled_rolling.lua"
local packer = nil
local packer_ok = nil
local command = rvim.command

-- toogle plugins easily
rvim.plugin = {
  -- SANE defaults
  SANE = { active = true },
  -- debug
  debug = { active = false },
  debug_ui = { active = false },
  dap_install = { active = false },
  osv = { active = false },
  -- lsp
  saga = { active = false },
  lightbulb = { active = true },
  symbols_outline = { active = false },
  bqf = { active = false },
  trouble = { active = false },
  nvim_lint = { active = false },
  formatter = { active = false },
  lsp_ts_utils = { active = true },
  -- treesitter
  treesitter = { active = false },
  playground = { active = true },
  rainbow = { active = false },
  matchup = { active = false },
  autotag = { active = false },
  autopairs = { active = true },
  -- editor
  fold_cycle = { active = false },
  accelerated_jk = { active = false },
  easy_align = { active = true },
  cool = { active = true },
  delimitmate = { active = false },
  eft = { active = false },
  cursorword = { active = false },
  surround = { active = true },
  dial = { active = true },
  -- tools
  fterm = { active = true },
  far = { active = true },
  bookmarks = { active = true },
  colorizer = { active = true },
  undotree = { active = false },
  fugitive = { active = false },
  rooter = { active = true },
  diffview = { active = true },
  -- TODO: handle these later
  glow = { active = false },
  doge = { active = false },
  dadbod = { active = false },
  restconsole = { active = false },
  markdown_preview = { active = true },
  -- aesth
  tree = { active = true },
  dashboard = { active = false },
  statusline = { active = false },
  git_signs = { active = false },
  indent_line = { active = false },
  -- completion
  emmet = { active = false },
  friendly_snippets = { active = true },
  vsnip = { active = true },
  telescope_fzy = { active = false },
  telescope_project = { active = false },
  telescope_media_files = { active = false },
}

local Plug = {}
Plug.__index = Plug

function Plug:get_plugins_list()
  local modules_dir = g.modules_dir
  local list = {}
  local tmp = vim.split(fn.globpath(modules_dir, "*/plugins.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#modules_dir - 6, -1)
  end
  return list
end

function Plug:load_plugins()
  self.repos = {}

  local plugins_file = Plug:get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function Plug:load_packer()
  if not packer then
    api.nvim_command "packadd packer.nvim"
    packer = require "packer"
  end

  packer_ok, packer = pcall(require, "packer")
  if not packer_ok then
    return
  end

  packer.init {
    package_root = install_path,
    compile_path = packer_compiled,
    auto_reload_compiled = true,
    git = { clone_timeout = 7000 },
    disable_commands = true,
    display = {
      open_fn = function()
        return require("packer.util").float { border = "single" }
      end,
    },
  }
  packer.reset()
  self:load_plugins()
  require("packer").startup(function(use)
    use { "wbthomason/packer.nvim", opt = true }
    for _, repo in ipairs(self.repos) do
      use(repo)
    end
  end)
end

function Plug:init_ensure_plugins()
  local packer_dir = g.data_dir .. "/site/pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(g.data_dir .. "/site/lua", 511, function()
      assert "make compile path dir faield"
    end)
    self:load_packer()
    packer.install()
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Plug:load_packer()
    end
    return packer[key]
  end,
})

function plugins.ensure_plugins()
  Plug:init_ensure_plugins()
end

function plugins.convert_compile_file()
  local lines = {}
  local lnum = 1
  lines[#lines + 1] = "vim.cmd [[packadd packer.nvim]]\n"

  for line in io.lines(packer_compiled) do
    lnum = lnum + 1
    if lnum > 15 then
      lines[#lines + 1] = line .. "\n"
      if line == "END" then
        break
      end
    end
  end
  table.remove(lines, #lines)

  if vim.fn.isdirectory(g.data_dir .. "/site/lua") ~= 1 then
    os.execute("mkdir -p " .. g.data_dir .. "/site/lua")
  end

  if vim.fn.filereadable(compile_to_lua) == 1 then
    os.remove(compile_to_lua)
  end

  local file = io.open(compile_to_lua, "w")
  for _, line in ipairs(lines) do
    file:write(line)
  end
  file:close()

  os.remove(packer_compiled)
end

function plugins.magic_compile()
  plugins.compile()
  plugins.convert_compile_file()
end

function plugins.auto_compile()
  local file = vim.fn.expand "%:p"
  if file:match(rvim.__modules_dir) then
    plugins.clean()
    plugins.compile()
    plugins.convert_compile_file()
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_to_lua) == 1 then
    require "_compiled_rolling"
  else
    assert "Missing packer compile file Run PackerCompile Or PackerInstall to fix"
    plugins.install()
    plugins.magic_compile()
  end
  command { "PlugCompile", [[call v:lua.require('core.plugins').magic_compile()]] }
  command { "PlugInstall", [[lua require('core.plugins').install()]] }
  command { "PlugSync", [[lua require('core.plugins').sync()]] }
  command { "PlugClean", [[lua require('core.plugins').clean()]] }
  command { "PlugUpdate", [[lua require('core.plugins').update()]] }
  command { "PlugStatus", [[lua require('core.plugins').status()]] }
  rvim.augroup("PackerComplete", {
    { events = { "User" }, targets = { "lua" }, command = "lua require('core.plugins').magic_compile()" },
  })
end

return plugins
