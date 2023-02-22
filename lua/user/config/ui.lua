local border = {
  common = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  line = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
  rectangle = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
  ui_select = {
    { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
    results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
    preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  },
}

local icons = {
  separators = {
    vert_bottom_half_block = '▄',
    vert_top_half_block = '▀',
    right_block = '🮉',
    medium_shade_block = '▒',
  },
  lsp = {
    error = '',
    warn = '',
    info = '',
    hint = '',
  },
  statusline = {
    bar = '▊',
    mode = '',
  },
  git = {
    branch = '',
    added = '',
    mod = '',
    removed = '',
    ignore = '',
    rename = '',
    diff = '',
    repo = '',
    logo = '',
    conflict = '',
    staged = '',
    unstaged = '',
    untracked = '',
  },
  documents = {
    file = '',
    files = '',
    folder = '',
    open_folder = '',
  },
  type = {
    array = '',
    number = '',
    object = '',
    null = '[]',
    float = '',
  },
  misc = {
    ellipsis = '…',
    up = '⇡',
    down = '⇣',
    line = 'ℓ', -- ''
    indent = 'Ξ',
    tab = '⇥',
    dap_red = '🛑',
    dap_hollow = '🟢',
    bug = '',
    bug_alt = '',
    question = '',
    clock = '',
    lock = '',
    circle = '',
    dot = '•',
    project = '',
    dashboard = '',
    history = '',
    comment = '',
    robot = 'ﮧ',
    smiley = 'ﲃ',
    lightbulb = '',
    search = '',
    search_alt = '',
    code = '',
    telescope = '',
    gear = '',
    package = '',
    list = '',
    sign_in = '',
    check = '',
    fire = '',
    note = '',
    bookmark = '',
    bookmark_alt = '',
    pencil = '',
    chevron_right = '',
    chevron_right_alt = '❯',
    arrow_right = '',
    caret_right = '',
    double_chevron_right = '»',
    table = '',
    calendar = '',
    tree = '',
    octoface = '',
    checkmark = '✓',
    right_arrow = '',
    right_arrow_alt = '',
    uninstalled = '✗',
    pick = '',
  },
  kind = {
    Class = '', -- '',
    Color = '',
    Constant = '', -- '',ﲀ
    Constructor = '',
    Enum = '練',
    EnumMember = '',
    Event = '',
    Field = '', -- '',
    File = '',
    Folder = '',
    Function = '',
    Interface = 'ﰮ',
    Keyword = '', -- '',
    Method = '',
    Module = '',
    Operator = '',
    Property = '',
    Reference = '', -- '',
    Snippet = '', -- '', '',
    Struct = '', -- 'פּ',
    Text = '',
    TypeParameter = '',
    Unit = '塞',
    Value = '',
    Variable = '', -- '',
    Namespace = '?',
    Package = '?',
    String = '?',
    Number = '?',
    Boolean = '?',
    Array = '?',
    Object = '?',
    Key = '?',
    Null = '?',
  },
}

local codicons = {
  kind = {
    Text = '',
    Method = '',
    Function = '',
    Constructor = '',
    Field = '',
    Variable = '',
    Class = '',
    Interface = '',
    Module = '',
    Property = '',
    Unit = '',
    Value = '',
    Enum = '',
    Keyword = '',
    Snippet = '',
    Color = '',
    File = '',
    Reference = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = '',
    Event = '',
    Operator = '',
    TypeParameter = '',
    Misc = '',
    Array = '',
    Boolean = '',
    Key = '',
    Object = '',
    String = '',
    Namespace = '',
    Package = '',
    Null = 'ﳠ',
    Number = '',
  },
  type = {
    array = '',
    number = '',
    string = '',
    boolean = '',
    object = '',
  },
  documents = {
    File = '',
    Files = '',
    Folder = '',
    OpenFolder = '',
  },
  git = {
    added = '',
    mod = '',
    removed = '',
    Ignore = '',
    Rename = '',
    Diff = '',
    Repo = '',
  },
  ui = {
    ArrowClosed = '',
    ArrowOpen = '',
    Lock = '',
    Circle = '',
    BigCircle = '',
    BigUnfilledCircle = '',
    Close = '',
    NewFile = '',
    Search = '',
    Lightbulb = '',
    Project = '',
    Dashboard = '',
    History = '',
    Comment = '',
    Bug = '',
    Code = '',
    Telescope = '',
    Gear = '',
    Package = '',
    List = '',
    SignIn = '',
    SignOut = '',
    NoteBook = '',
    Check = '',
    Fire = '',
    Note = '',
    BookMark = '',
    Pencil = '',
    ChevronRight = '',
    Table = '',
    Calendar = '',
    CloudDownload = '',
  },
  lsp = {
    error = '',
    warn = '',
    info = '',
    hint = '', -- alt: 
    trace = '✎',
  },
  misc = {
    robot = '',
    squirrel = '',
    tag = '',
    watch = '',
    Smiley = '',
    Package = '',
    CircuitBoard = '',
  },
}

----------------------------------------------------------------------------------------------------
-- UI Settings
----------------------------------------------------------------------------------------------------
---@class UiSetting {
---@field winbar boolean
---@field number 'ignore' | boolean
---@field statusline 'minimal' | boolean
---@field statuscolumn boolean
---@field colorcolumn boolean

---@alias UiSettings {buftypes: table<string, UiSetting>, filetypes: table<string, UiSetting>}

---@class UiSetting
local Preset = {}

---@param o UiSetting
function Preset:new(o)
  assert(o, 'a present must be defined')
  self.__index = self
  return setmetatable(o, self)
end

--- WARNING: deep extend does not copy lua meta methods
function Preset:with(o) return vim.tbl_deep_extend('force', self, o) end

---@type table<string, UiSetting>
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

local commit_buffer = presets.minimal_editing:with({
  colorcolumn = true,
  winbar = false,
})

---@type UiSettings
local settings = {
  buftypes = {
    ['terminal'] = presets.tool_panel,
    ['quickfix'] = presets.tool_panel,
    ['nofile'] = presets.tool_panel,
    ['nowrite'] = presets.tool_panel,
    ['acwrite'] = presets.tool_panel,
  },
  filetypes = {
    ['checkhealth'] = presets.tool_panel,
    ['help'] = presets.tool_panel,
    ['dapui'] = presets.tool_panel,
    ['Trouble'] = presets.tool_panel,
    ['dap-repl'] = presets.tool_panel,
    ['tsplayground'] = presets.tool_panel,
    ['list'] = presets.tool_panel,
    ['netrw'] = presets.tool_panel,
    ['NvimTree'] = presets.tool_panel,
    ['undotree'] = presets.tool_panel,
    ['NeogitPopup'] = presets.tool_panel,
    ['NeogitStatus'] = presets.tool_panel,
    ['neo-tree'] = presets.tool_panel:with({ winbar = 'ignore' }),
    ['toggleterm'] = presets.tool_panel:with({ winbar = 'ignore' }),
    ['NeogitCommitSelectView'] = presets.tool_panel,
    ['NeogitRebaseTodo'] = presets.tool_panel,
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
  },
}

---Get the UI setting for a particular filetype
---@param key string
---@param setting 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'
---@param t 'ft'|'bt'
---@return (boolean | string)?
function settings.get(key, setting, t)
  if not key or not setting then return nil end
  if t == 'ft' then return settings.filetypes[key] and settings.filetypes[key][setting] end
  if t == 'bt' then return settings.buftypes[key] and settings.buftypes[key][setting] end
end

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Global style settings
----------------------------------------------------------------------------------------------------
-- Some styles can be tweak here to apply globally i.e. by setting the current value for that style
-- The current styles for various UI elements
local current = { border = border.line, lsp_icons = codicons.kind }

rvim.ui.icons = icons
rvim.ui.codicons = codicons
rvim.ui.border = border
rvim.ui.current = current
rvim.ui.settings = settings
