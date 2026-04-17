if not ar then return end

local enabled = ar.config.plugin.core.rooter.enable

if ar.none or not enabled then return end

-- https://github.com/swaits/tiny-rooter.nvim/blob/main/lua/tiny-rooter/init.lua

-- stylua: ignore
local markers = { '.git', 'Makefile', 'go.mod', 'go.sum', '.jj', 'Cargo.toml', 'pyproject.toml', 'package.json' }

---@param args AutocmdArgs
local function set_root(args)
  local root = vim.fs.root(args.buf, markers)
  if not root then return end
  if root == vim.fn.getcwd() then return end
  vim.cmd.lcd(root)

  -- reset worktree and gitdir (if set, re: baredot)
  vim.env.GIT_WORK_TREE = nil
  vim.env.GIT_DIR = nil
end

ar.augroup('FindProjectRoot', { event = { 'BufEnter' }, command = set_root })
