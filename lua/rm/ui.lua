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
  misc = {
    chevron_right = '',
    checkmark = '✓',
    dap_green = '🟢',
    dap_red = '🛑',
    double_chevron_right = '»',
    ellipsis = '…',
    lightbulb = '',
    right_arrow = '',
    uninstalled = '✗',
    active_ts = '',
    spell_check = '󰓆',
    triangle = '',
    triangle_short = '▶',
    triangle_short_right = '',
    triangle_short_down = '',
    down = '',
    up = '󰁝',
    separator = '➤',
    dot = '',
  },
  separators = {
    left_thin_block = '▏',
    right_thin_block = '▕',
    dotted_thin_block = '',
    left_block = '▎',
    middle_block = '│',
    right_bold_block = '🮉',
    light_shade_block = '░',
    medium_shade_block = '▒',
    bar = '▊',
  },
}

rvim.ui.codicons = {
  documents = {
    new_file = '',
    default_file = '',
    file = '',
    files = '',
    folder = '',
    empty_folder = '',
    open_folder = '',
    open_folder_alt = '',
  },
  git = {
    added = '',
    removed = '',
    mod = '',
    renamed = '',
    untracked = '',
    ignored = '',
    unstaged = '󰄗', --󰄱
    staged = '󰄵',
    conflict = '',
    added_alt = '',
    diff = '',
    diff_alt = '',
    logo = '󰊢',
    repo = '',
    repo_alt = '',
  },
  lsp = {
    error = '󰅚',
    warn = '󰀪',
    info = '󰋽',
    hint = '󰌶', -- alt: 
    trace = '✎',
  },
  lsp_alt = {
    error = '󰅙', -- alt: 
    warn = '󰀦',
    info = '󰋼', --  ℹ 󰙎 
    hint = '󰌵',
  },
  misc = {
    bookmark = '', -- 
    bug = '',
    calendar = '',
    circle = '',
    circuit_board = '',
    code = '',
    clock = '',
    comment = '󰅺',
    lightbulb = '󰌵',
    package = '',
    octoface = '',
    pick = '󰋇',
    project = '',
    robot = '󰚩', -- 
    search = '󰍉',
    search_alt = '',
    shaded_lock = '',
    smiley = '',
    squirrel = '',
    table = '',
    tag = '',
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
    Null = 'Error',
    EnumMember = '@field',
  },
}
--------------------------------------------------------------------------------
-- UI Settings
--------------------------------------------------------------------------------
---@class Decorations {
---@field winbar boolean
---@field number 'ignore' | boolean
---@field statusline 'minimal' | boolean
---@field statuscolumn boolean
---@field colorcolumn boolean | string

---@alias DecorationType 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'

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

local commit_buffer =
  presets.minimal_editing:with({ colorcolumn = '50,72', winbar = false })
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
  ['log'] = presets.tool_panel,
  ['httpResult'] = presets.tool_panel,
  ['help'] = presets.tool_panel,
  ['^copilot.*'] = presets.tool_panel,
  ['dapui'] = presets.tool_panel,
  ['Trouble'] = presets.tool_panel,
  ['tsplayground'] = presets.tool_panel,
  ['list'] = presets.tool_panel,
  ['netrw'] = presets.tool_panel,
  ['NvimTree'] = presets.tool_panel,
  ['oil'] = presets.tool_panel,
  ['lazy'] = presets.tool_panel,
  ['undotree'] = presets.tool_panel,
  ['dap-repl'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['neo-tree'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['toggleterm'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['neotest.*'] = presets.tool_panel,
  ['^Neogit.*'] = presets.tool_panel,
  ['agitator'] = presets.tool_panel,
  ['aerial'] = presets.tool_panel,
  ['blame'] = presets.tool_panel,
  ['query'] = presets.tool_panel,
  ['DiffviewFiles'] = presets.tool_panel,
  ['DiffviewFileHistory'] = presets.tool_panel,
  ['diff'] = presets.statusline_only,
  ['qf'] = presets.statusline_only,
  ['alpha'] = presets.tool_panel:with({ statusline = false }),
  ['fugitive'] = presets.statusline_only,
  ['startify'] = presets.statusline_only,
  ['man'] = presets.minimal_editing,
  ['org'] = presets.minimal_editing:with({ winbar = false }),
  ['norg'] = presets.minimal_editing:with({ winbar = false }),
  ['orgagenda'] = presets.minimal_editing:with({ winbar = false }),
  ['markdown'] = presets.minimal_editing,
  ['gitcommit'] = commit_buffer,
  ['NeogitCommitMessage'] = commit_buffer,
  ['slide'] = presets.tool_panel:with({ winbar = 'ignore' }),
})

local filenames = rvim.p_table({
  ['option-window'] = presets.tool_panel,
})

rvim.ui.decorations = {}

---@alias ui.OptionValue (boolean | string)

---Get the UI setting for a particular filetype
---@param opts {ft: string?, bt: string?, fname: string?, setting: DecorationType}
---@return {ft: ui.OptionValue?, bt: ui.OptionValue?, fname: ui.OptionValue?} | nil
function rvim.ui.decorations.get(opts)
  local ft, bt, fname, setting = opts.ft, opts.bt, opts.fname, opts.setting
  if (not ft and not bt and not fname) or not setting then return nil end
  return {
    ft = ft and filetypes[ft] and filetypes[ft][setting],
    bt = bt and buftypes[bt] and buftypes[bt][setting],
    fname = fname and filenames[fname] and filenames[fname][setting],
  }
end

---A helper to set the value of the colorcolumn option, to my preferences, this can be used
---in an autocommand to set the `vim.opt_local.colorcolumn` or by a plugin such rvim `virtcolumn.nvim`
---to set it's virtual column
---@param bufnr integer
---@param fn fun(colorcolumn: string | boolean)
function rvim.ui.decorations.set_colorcolumn(bufnr, fn)
  local buf = vim.bo[bufnr]
  local decor = rvim.ui.decorations.get({
    ft = buf.ft,
    bt = buf.bt,
    setting = 'colorcolumn',
  })
  local ccol = decor and decor.ft or decor and decor.bt or ''
  local colorcolumn = not rvim.falsy(ccol) and ccol or '+1'
  if
    buf.ft == ''
    or buf.bt ~= ''
    or decor and decor.ft == false
    or decor and decor.bt == false
  then
    colorcolumn = ''
  end
  if vim.is_callable(fn) then fn(colorcolumn) end
end

--------------------------------------------------------------------------------
-- The current styles for various UI elements
rvim.ui.current = { border = rvim.ui.border.line }
