-------------------------------------------------------------------------------
---Big File feature disabling
---based on https://github.com/LunarVim/bigfile.nvim/blob/33eb067e3d7029ac77e081cfe7c45361887a311a/lua/bigfile/init.lua

local config = {
  enable = false,
  bigfile_filesize = 500,
}

---@param bufnr number
---@return integer|nil size in MiB if buffer is valid, nil otherwise
local function get_buf_size(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, stats = pcall(
    function() return vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr)) end
  )
  if not (ok and stats) then return end
  return math.floor(0.5 + (stats.size / 1024))
end

---@param bufnr number
local function pre_bufread_callback(bufnr)
  vim.api.nvim_create_autocmd({ 'LspAttach' }, {
    buffer = bufnr,
    callback = function(args)
      vim.schedule(
        function() vim.lsp.buf_detach_client(bufnr, args.data.client_id) end
      )
    end,
  })

  ----------
  --   "treesitter",
  --   I don't think I can can simplify this without by doing this in the treesitter
  --   config since I think other plugins can add modules
  local is_ts_configured = false
  local function configure_treesitter()
    local status_ok, ts_config = pcall(require, 'nvim-treesitter.configs')
    if not status_ok then return end

    local disable_cb = function(_, buf)
      local detected = vim.b[buf].is_big_file_treesitter_disabled == true
      return detected
    end

    for _, mod_name in ipairs(ts_config.available_modules()) do
      local module_config = ts_config.get_module(mod_name) or {}
      local old_disabled = module_config.disable
      module_config.disable = function(lang, buf)
        return disable_cb(lang, buf)
          or (type(old_disabled) == 'table' and vim.tbl_contains(
            old_disabled,
            lang
          ))
          or (type(old_disabled) == 'function' and old_disabled(lang, buf))
      end
    end

    is_ts_configured = true
  end
  if not is_ts_configured then configure_treesitter() end

  vim.b[bufnr].is_big_file_treesitter_disabled = true

  ----------
  --   "matchparen",
  if vim.fn.exists(':DoMatchParen') ~= 2 then return end
  vim.cmd('NoMatchParen')

  ----------
  --   "syntax",
  vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    callback = function()
      vim.cmd('syntax clear')
      vim.opt_local.syntax = 'OFF'
    end,
    buffer = bufnr,
  })

  vim.bo.swapfile = false
  vim.wo.foldmethod = 'manual'
  vim.bo.undolevels = -1
  vim.go.undoreload = 0
  vim.wo.list = false
  vim.wo.spell = false

  vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    callback = function() vim.bo.filetype = '' end,
    buffer = bufnr,
  })
end

ar.augroup('bigfile', {
  event = 'BufReadPre',
  pattern = '*',
  command = function(args)
    if not config.enable then return end

    if vim.b[args.buf].is_big_file == true then return end

    local filesize = get_buf_size(args.buf)
    local bigfile_detected = (
      filesize ~= nil and filesize >= config.bigfile_filesize
    )

    vim.b[args.buf].is_big_file = bigfile_detected
    if not bigfile_detected then return end

    vim.notify('bigfile')
    pre_bufread_callback(args.buf)
  end,
  desc = string.format(
    'Performance rule for handling files over %sMiB',
    config.bigfile_filesize
  ),
})
