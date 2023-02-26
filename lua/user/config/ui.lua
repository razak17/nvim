rvim.ui.border = {
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

rvim.ui.icons = {
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

rvim.ui.codicons = {
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
local filetypes = {
  ['checkhealth'] = presets.tool_panel,
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
}

---@type UiSettings
rvim.ui.decorations = { filetypes = filetypes, buftypes = buftypes }

--- When searching through the filetypes table if a match can't be found then search
--- again but check if there is matching lua pattern. This is useful for filetypes for
--- plugins like Neogit which have a filetype of Neogit<something>.
setmetatable(filetypes, {
  __index = function(tbl, key)
    if not key then return end
    for k, v in pairs(tbl) do
      if key:match(k) then return v end
    end
  end,
})

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
rvim.ui.current = { border = rvim.ui.border.line, lsp_icons = rvim.ui.codicons.kind }
