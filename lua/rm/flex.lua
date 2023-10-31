if not rvim then return end

if rvim.none then
  return {
    'abeldekat/lazyflex.nvim',
    import = 'lazyflex.hook',
    opts = {
      filter_modules = { enabled = true },
      enable_match = false,
    },
  }
end

if not rvim.plugins.enable then
  return {
    'abeldekat/lazyflex.nvim',
    import = 'lazyflex.hook',
    opts = {
      kw = { 'onedark', 'accelerated-jk' },
    },
  }
end

local smart_extend = rvim.smart_extend

local disabled = rvim.plugins.disabled
local disabled_plugins = disabled.main

if not rvim.ai.enable then smart_extend(disabled_plugins, disabled.ai) end

if rvim.plugins.minimal and not rvim.is_git_repo() then
  smart_extend(disabled_plugins, disabled.git)
end

if not rvim.lsp.enable then smart_extend(disabled_plugins, disabled.lsp) end

if rvim.plugins.minimal then
  smart_extend(disabled_plugins, disabled.minimal)
end

if not rvim.treesitter.enable then
  smart_extend(disabled_plugins, disabled.treesitter)
end

-- null-ls
if not rvim.lsp.null_ls.enable then
  smart_extend(disabled_plugins, { 'none-ls', 'mason-null-ls' })
end

-- conform and nvim-lint
if rvim.lsp.null_ls.enable then
  smart_extend(disabled_plugins, { 'conform', 'nvim-lint' })
end

return {
  'abeldekat/lazyflex.nvim',
  import = 'lazyflex.hook',
  opts = {
    enable_match = false,
    kw = disabled_plugins,
  },
}
