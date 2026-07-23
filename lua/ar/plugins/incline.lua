local special_filetypes = {
  'neotest-output-panel',
  'neotest-summary',
  'noice',
  'trouble',
  'OverseerList',
}

local special_ft_titles = {
  ['neotest-output-panel'] = 'neotest',
  ['neotest-summary'] = 'neotest',
  noice = 'noice',
  trouble = 'trouble',
  OverseerList = 'overseer',
}
local function is_special_group(props)
  return vim.tbl_contains(special_filetypes, vim.bo[props.buf].filetype)
end

local function get_title(props)
  local title = ' ' .. special_ft_titles[vim.bo[props.buf].filetype] .. ' '
  return { { title, group = props.focused and 'FloatTitle' or 'Title' } }
end

---@param element any
---@param table any
---@return boolean
local function contains(element, table)
  for _, value in pairs(table) do
    if value == element then return true end
  end
  return false
end

return {
  {
    'b0o/incline.nvim',
    cond = function() return ar.get_plugin_cond('incline.nvim') end,
    event = 'VeryLazy',
    config = function()
      require('incline').setup(
        ---@module 'incline'
        {
          window = {
            zindex = 30,
          },
          hide = {
            cursorline = 'focused_win',
          },
          debounce_threshold = {
            falling = 50,
            rising = 50,
          },
          ignore = {
            buftypes = {},
            filetypes = { 'toggleterm' },
            unlisted_buffers = false,
          },
          render = function(props)
            if is_special_group(props) then
              return get_title(props)
            else
              local unhelpfuls = {
                'init.lua',
                'index.tsx',
                'index.ts',
                'index.js',
                'index.jsx',
                '__init__.py',
                '+page.svelte',
              }
              local filename =
                vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
              if contains(filename, unhelpfuls) then
                local full_path = vim.api.nvim_buf_get_name(props.buf)
                filename = vim.fn.fnamemodify(full_path, ':h:t')
                  .. '/'
                  .. vim.fn.fnamemodify(full_path, ':t')
              end
              local codicons = ar.ui.codicons
              local ft_icon = codicons.documents.default_file
              local ft_color = 'DevIconDefault'
              local modified = vim.bo[props.buf].modified and 'bold,italic'
                or 'bold'

              local ok, devicons = pcall(require, 'nvim-web-devicons')
              if ok then
                ft_icon, ft_color = devicons.get_icon_color(filename)
              end

              local function get_git_signs()
                local status_dict = vim.b[props.buf].gitsigns_status_dict
                if not status_dict then return {} end
                local has_changes = status_dict.added ~= 0
                  or status_dict.removed ~= 0
                  or status_dict.changed ~= 0

                if not has_changes then return {} end

                local labels = {}
                local git_codicons = codicons.git

                if not ar.falsy(status_dict.added) then
                  table.insert(labels, {
                    git_codicons.added .. ' ' .. status_dict.added .. ' ',
                    group = 'StatusLineGitDiffAdded',
                  })
                end

                if not ar.falsy(status_dict.removed) then
                  table.insert(labels, {
                    git_codicons.removed .. ' ' .. status_dict.removed .. ' ',
                    group = 'StatusLineGitDiffRemoved',
                  })
                end

                if not ar.falsy(status_dict.changed) then
                  table.insert(labels, {
                    git_codicons.mod .. ' ' .. status_dict.changed .. ' ',
                    group = 'StatusLineGitDiffChanged',
                  })
                end

                if #labels > 0 then table.insert(labels, { ' ' }) end

                return labels
              end

              local function get_diagnostic_label()
                local diag_icons = {
                  { severity = 'error', icon = codicons.lsp.error .. ' ' },
                  { severity = 'warn', icon = codicons.lsp.warn .. ' ' },
                  { severity = 'info', icon = codicons.lsp.info .. ' ' },
                  { severity = 'hint', icon = codicons.lsp.hint .. ' ' },
                }
                local label = {}
                for _, d in ipairs(diag_icons) do
                  local severity, icon = d.severity, d.icon
                  local s = vim.diagnostic.severity[string.upper(d.severity)]
                  local n = vim.diagnostic.count(props.buf, { severity = s })[s]
                    or 0
                  if n > 0 then
                    table.insert(
                      label,
                      { icon .. n .. ' ', group = 'DiagnosticSign' .. severity }
                    )
                  end
                end
                if #label > 0 then table.insert(label, { ' ' }) end
                return label
              end

              local buffer = {
                { get_diagnostic_label() },
                { get_git_signs() },
                { (ft_icon or '') .. ' ', guifg = ft_color, guibg = 'none' },
                { filename .. ' ', gui = modified },
              }
              return buffer
            end
          end,
        }
      )
    end,
  },
}
