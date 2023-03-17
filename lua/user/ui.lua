rvim.ui.border = {
  common = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  line = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
  rectangle = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
  ivy = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' },
  ui_select = {
    { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
    results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
    preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  },
}

rvim.ui.icons = {
  git = { branch = '', untracked = '' },
  separators = {
    left_thin_block = '▏',
    vert_bottom_half_block = '▄',
    vert_top_half_block = '▀',
    right_block = '🮉',
    light_shade_block = '░',
    medium_shade_block = '▒',
    bar = '▊',
  },
  ui = {
    triangle = '',
    chevron_right = '',
    checkmark = '✓',
    dap_green = '🟢',
    dap_red = '🛑',
    double_chevron_right = '»',
    ellipsis = '…',
    lightbulb = '',
    right_arrow = '',
    uninstalled = '✗',
  },
}

rvim.ui.codicons = {
  documents = {
    new_file = '',
    file = '',
    files = '',
    folder = '',
    folder_alt = '',
    open_folder = '',
    open_folder_alt = '',
  },
  git = {
    added = '',
    added_alt = '',
    diff = '',
    diff_alt = '',
    ignored = '',
    logo = '',
    mod = '',
    removed = '',
    renamed = '',
    repo = '',
    repo_alt = '',
    staged = '',
    unstaged = '',
  },
  ui = {
    bug = '',
    calendar = '',
    code = '',
    clock = '',
    filled_circle = '',
    package = '',
    octoface = '',
    pick = '',
    Project = '',
    search = '',
    search_alt = '',
    table = '',
  },
  lsp = {
    error = '',
    warn = '',
    info = '',
    hint = '', -- alt: 
    trace = '✎',
  },
  lsp_alt = {
    error = '', -- alt: 
    warn = '',
    info = '',
    hint = '',
  },
  misc = {
    robot = '',
    squirrel = '',
    tag = '',
    smiley = '',
    circuit_board = '',
  },
}

rvim.ui.lsp = {
  --- LSP Kinds come via the LSP spec
  --- see: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
  highlights = {
    Text = '@string',
    Method = '@method',
    Function = '@function',
    Constructor = '@constructor',
    Field = '@field',
    Variable = '@variable',
    Class = '@storageclass',
    Interface = '@constant',
    Module = '@include',
    Property = '@property',
    Unit = '@constant',
    Value = '@variable',
    Enum = '@type',
    Keyword = '@keyword',
    File = 'Directory',
    Reference = '@preProc',
    Constant = '@constant',
    Struct = '@type',
    Snippet = '@label',
    Event = '@variable',
    Operator = '@operator',
    TypeParameter = '@type',
    Namespace = '@namespace',
    Package = '@include',
    String = '@string',
    Number = '@number',
    Boolean = '@boolean',
    Array = '@storageclass',
    Object = '@type',
    Key = '@field',
    Null = '@error',
    EnumMember = '@field',
  },
  kinds = {
    codicons = {
      Array = '',
      Boolean = '',
      Class = '',
      Color = '',
      Constant = '',
      Constructor = '',
      Enum = '',
      EnumMember = '',
      Event = '',
      Field = '',
      File = '',
      Folder = '',
      Function = '',
      Interface = '',
      Key = '',
      Keyword = '',
      Method = '',
      Module = '',
      Namespace = '',
      Null = 'ﳠ',
      Number = '',
      Object = '',
      Operator = '',
      Package = '',
      Property = '',
      Reference = '',
      Snippet = '',
      String = '',
      Struct = '',
      Text = '',
      TypeParameter = '',
      Unit = '',
      Value = '',
      Variable = '',
    },
  },
}
----------------------------------------------------------------------------------------------------
-- UI Settings
----------------------------------------------------------------------------------------------------
---@class Decorations {
---@field winbar boolean
---@field number 'ignore' | boolean
---@field statusline 'minimal' | boolean
---@field statuscolumn boolean
---@field colorcolumn boolean | string

---@alias UiSettings {buftypes: table<string, Decorations>, filetypes: table<string, Decorations>}

---@class Decorations
local Preset = {}

---@param o Decorations
function Preset:new(o)
  assert(o, 'a present must be defined')
  self.__index = self
  return setmetatable(o, self)
end

--- WARNING: deep extend does not copy lua meta methods
function Preset:with(o) return vim.tbl_deep_extend('force', self, o) end

---@type table<string, Decorations>
local presets = {
  statusline_only = Preset:new({
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = true,
    statuscolumn = false,
  }),
  minimal_editing = Preset:new({
    number = false,
    winbar = true,
    colorcolumn = false,
    statusline = true,
    statuscolumn = false,
  }),
  tool_panel = Preset:new({
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = 'minimal',
    statuscolumn = false,
  }),
}

local commit_buffer = presets.minimal_editing:with({ colorcolumn = '50,72', winbar = false })
local buftypes = {
  ['terminal'] = presets.tool_panel,
  ['quickfix'] = presets.tool_panel,
  ['nofile'] = presets.tool_panel,
  ['nowrite'] = presets.tool_panel,
  ['acwrite'] = presets.tool_panel,
}

--- When searching through the filetypes table if a match can't be found then search
--- again but check if there is matching lua pattern. This is useful for filetypes for
--- plugins like Neogit which have a filetype of Neogit<something>.
local filetypes = rvim.p_table({
  ['checkhealth'] = presets.tool_panel,
  ['httpResult'] = presets.tool_panel,
  ['help'] = presets.tool_panel,
  ['dapui'] = presets.tool_panel,
  ['Trouble'] = presets.tool_panel,
  ['tsplayground'] = presets.tool_panel,
  ['list'] = presets.tool_panel,
  ['netrw'] = presets.tool_panel,
  ['NvimTree'] = presets.tool_panel,
  ['undotree'] = presets.tool_panel,
  ['dap-repl'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['neo-tree'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['toggleterm'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['neotest.*'] = presets.tool_panel,
  ['^Neogit.*'] = presets.tool_panel,
  ['query'] = presets.tool_panel,
  ['DiffviewFiles'] = presets.tool_panel,
  ['DiffviewFileHistory'] = presets.tool_panel,
  ['diff'] = presets.statusline_only,
  ['qf'] = presets.statusline_only,
  ['alpha'] = presets.tool_panel:with({ statusline = false }),
  ['fugitive'] = presets.statusline_only,
  ['startify'] = presets.statusline_only,
  ['man'] = presets.minimal_editing,
  ['markdown'] = presets.minimal_editing,
  ['gitcommit'] = commit_buffer,
  ['NeogitCommitMessage'] = commit_buffer,
})

---@type UiSettings
rvim.ui.decorations = { filetypes = filetypes, buftypes = buftypes }

---Get the UI setting for a particular filetype
---@param key string
---@param setting 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'
---@param t 'ft'|'bt'
---@return (boolean | string)?
function rvim.ui.decorations.get(key, setting, t)
  if not key or not setting then return nil end
  if t == 'ft' then return filetypes[key] and filetypes[key][setting] end
  if t == 'bt' then return buftypes[key] and buftypes[key][setting] end
end

---A helper to set the value of the colorcolumn option, to my preferences, this can be used
---in an autocommand to set the `vim.opt_local.colorcolumn` or by a plugin such as `virtcolumn.nvim`
---to set it's virtual column
---@param bufnr integer
---@param fn fun(virtcolumn: string)
function rvim.ui.decorations.set_colorcolumn(bufnr, fn)
  local buf = vim.bo[bufnr]
  local ft_ccol = rvim.ui.decorations.get(buf.ft, 'colorcolumn', 'ft')
  local bt_ccol = rvim.ui.decorations.get(buf.bt, 'colorcolumn', 'bt')
  if buf.ft == '' or buf.bt ~= '' or ft_ccol == false or bt_ccol == false then return end
  local ccol = ft_ccol or bt_ccol or ''
  local virtcolumn = not rvim.empty(ccol) and ccol or '+1'
  if vim.is_callable(fn) then fn(virtcolumn) end
end

----------------------------------------------------------------------------------------------------
-- The current styles for various UI elements
rvim.ui.current = { border = rvim.ui.border.line, lsp_icons = rvim.ui.lsp.kinds.codicons }
