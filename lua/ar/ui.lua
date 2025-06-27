ar.ui.border = {
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

ar.ui.spinners = {
  -- stylua: ignore
  common = { '', '󰪞', '󰪟', '󰪠', '󰪡', '󰪢', '󰪣', '󰪤', '󰪥', '' },
  alt = { '󰧞󰧞', '󰧞󰧞', '󰧞󰧞', '󰧞󰧞' },
}

ar.ui.icons = {
  scrollbars = {
    -- stylua: ignore
    wide = { '__', '▁▁', '▂▂', '▃▃', '▄▄', '▅▅', '▆▆', '▇▇', '██', },
    thin = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
  },
  git = { branch = '', untracked = '' },
  misc = {
    arrow_up = '', -- ⇡
    arrow_down = '', -- ⇣
    beaker = '',
    block = '■',
    block_alt = '󱓻',
    block_medium = '',
    chevron_right = '',
    chevron_down = '',
    chevron_right_alt = '',
    checkmark = '✓',
    dap_green = '🟢',
    dap_red = '🛑',
    double_chevron_right = '»',
    ellipsis = '…',
    ghost = '󰊠',
    test_tube = '󰙨',
    lightbulb = '',
    processing = '',
    right_arrow = '',
    uninstalled = '✗',
    active_ts = '',
    spell_check = '󰓆',
    triangle = '',
    triangle_long = '▶',
    triangle_long_down = '▼',
    triangle_short_right = '',
    triangle_short_down = '',
    down = '',
    up = '󰁝',
    separator = '➤',
    dot = '',
    dot_alt = '',
    play = '',
  },
  -- ┃, ┆, ┇, ┊, ┋, ╎, ╏, ║, ╽, ╿)
  separators = {
    left_thin_block = '▏',
    right_thin_block = '▕',
    dotted_thin_block = '',
    dotted_block = '┊',
    left_block = '▎',
    middle_block = '│',
    right_bold_block = '🮉',
    light_shade_block = '░',
    medium_shade_block = '▒',
    bar = '▊',
  },
}

ar.ui.codicons = {
  ai = {
    deepseek = '',
    groq = '',
    ollama = '󰳆',
    open_router = '󱂇',
    llama = '󰳆',
    claude = '󰋦',
    codestral = '󱎥',
    gemini = '',
    minuet = '󱗻',
    openai = '󱢆',
  },
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
    branch = '',
    pending = '',
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
    block = '',
    bookmark = '', --  ⚑
    buffers = '󱂬',
    bug = '',
    bug_alt = '',
    calendar = '',
    circle = '',
    circuit_board = '',
    clock = '',
    code = '',
    cmd = '',
    comment = '󰅺',
    connect = '󱘖',
    copilot = '',
    disconnect = '',
    gpt = '🤖',
    hash = '',
    lightbulb = '󰌵',
    model = '󰒡',
    nerd_font = '',
    null_ls = '␀',
    null = '',
    octoface = '',
    package = '',
    pick = '󰋇',
    project = '',
    robot = '󰚩', -- 
    robot_alt = '󱙺', -- 
    search = '󰍉',
    search_alt = '',
    cloud_check = '󰅠',
    cloud_outline = '',
    lock = '󰌾',
    lock_outline = '',
    smiley = '',
    squirrel = '',
    table = '',
    tabs = '󰓩',
    tag = '',
    terminal = '',
    tree = '', -- 󰁳
  },
}

ar.ui.lsp = {
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
---@field cursorline boolean | string

---@alias DecorationType 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'|'cursorline'

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
    cursorline = false,
  }),
  minimal_editing = Preset:new({
    number = false,
    winbar = true,
    colorcolumn = false,
    statusline = true,
    statuscolumn = false,
    cursorline = true,
  }),
  tool_panel = Preset:new({
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = 'minimal',
    statuscolumn = false,
    cursorline = false,
  }),
}

local commit_buffer =
  presets.minimal_editing:with({ colorcolumn = '50,72', winbar = false })
local buftypes = {
  ['acwrite'] = presets.tool_panel,
  ['nofile'] = presets.tool_panel,
  ['nowrite'] = presets.tool_panel,
  ['prompt'] = presets.tool_panel,
  ['quickfix'] = presets.tool_panel,
  ['terminal'] = presets.tool_panel,
}

--- When searching through the filetypes table if a match can't be found then search
--- again but check if there is matching lua pattern. This is useful for filetypes for
--- plugins like Neogit which have a filetype of Neogit<something>.
local filetypes = ar.p_table({
  ['^Neogit.*'] = presets.tool_panel:with({
    cursorline = true,
    statusline = true,
  }),
  ['^copilot.*'] = presets.tool_panel,
  ['aerial'] = presets.tool_panel,
  ['agitator'] = presets.tool_panel,
  ['alpha'] = presets.tool_panel:with({ statusline = false }),
  ['arena'] = presets.tool_panel:with({ number = true }),
  ['Avante'] = presets.tool_panel,
  ['blame'] = presets.tool_panel,
  ['bufexplorer'] = presets.tool_panel,
  ['buffalo'] = presets.tool_panel:with({ number = true }),
  ['buffer_manager'] = presets.tool_panel:with({ number = true }),
  ['checkhealth'] = presets.tool_panel,
  ['codecompanion'] = presets.statusline_only,
  ['compile'] = presets.statusline_only,
  ['dap-repl'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['dapui'] = presets.tool_panel,
  ['dbout'] = presets.tool_panel,
  ['diagmsg'] = presets.tool_panel,
  ['diff'] = presets.statusline_only,
  ['DiffviewFileHistory'] = presets.tool_panel,
  ['DiffviewFiles'] = presets.tool_panel,
  ['DressingInput'] = presets.tool_panel,
  ['fugitive'] = presets.statusline_only:with({ cursorline = true }),
  ['fzf'] = presets.tool_panel,
  ['gitcommit'] = commit_buffer,
  ['grug-far'] = presets.tool_panel,
  ['harpoon'] = presets.tool_panel,
  ['help'] = presets.tool_panel:with({ cursorline = true }),
  ['http'] = presets.tool_panel:with({ statusline = true }),
  ['httpResult'] = presets.tool_panel,
  ['lazy'] = presets.tool_panel,
  ['list'] = presets.tool_panel,
  ['log'] = presets.tool_panel,
  ['man'] = presets.minimal_editing,
  -- ['markdown'] = presets.minimal_editing,
  ['neo-tree'] = presets.tool_panel:with({
    winbar = 'ignore',
    cursorline = true,
  }),
  ['NeogitCommitMessage'] = commit_buffer,
  ['neotest.*'] = presets.tool_panel,
  ['netrw'] = presets.tool_panel,
  ['noice'] = presets.tool_panel,
  ['norg'] = presets.minimal_editing:with({ winbar = false }),
  ['notify'] = presets.tool_panel,
  ['NvimTree'] = presets.tool_panel,
  ['outputpanel'] = presets.tool_panel,
  ['oil'] = presets.tool_panel,
  ['org'] = presets.minimal_editing:with({ winbar = false }),
  ['orgagenda'] = presets.minimal_editing:with({ winbar = false }),
  ['qf'] = presets.tool_panel,
  -- ['query'] = presets.tool_panel,
  ['slide'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['snacks_notif_history'] = presets.tool_panel,
  ['snacks_picker_input'] = presets.tool_panel:with({ statuscolumn = true }),
  ['starter'] = presets.tool_panel:with({ statusline = false }),
  ['startify'] = presets.statusline_only,
  ['startup'] = presets.tool_panel:with({ statusline = false }),
  ['toggleterm'] = presets.tool_panel:with({ winbar = 'ignore' }),
  ['TelescopePrompt'] = presets.tool_panel,
  ['Trouble'] = presets.tool_panel,
  ['tsplayground'] = presets.tool_panel,
  ['undotree'] = presets.tool_panel,
  ['w3m'] = presets.tool_panel:with({ statusline = false }),
})

local filenames = ar.p_table({
  ['option-window'] = presets.tool_panel,
})

ar.ui.decorations = {}

---@alias ui.OptionValue (boolean | string)

---Get the UI setting for a particular filetype
---@param opts {ft: string?, bt: string?, fname: string?, setting: DecorationType}
---@return {ft: ui.OptionValue?, bt: ui.OptionValue?, fname: ui.OptionValue?} | nil
function ar.ui.decorations.get(opts)
  local ft, bt, fname, setting = opts.ft, opts.bt, opts.fname, opts.setting
  if (not ft and not bt and not fname) or not setting then return nil end
  return {
    ft = ft and filetypes[ft] and filetypes[ft][setting],
    bt = bt and buftypes[bt] and buftypes[bt][setting],
    fname = fname and filenames[fname] and filenames[fname][setting],
  }
end

---A helper to set the value of the colorcolumn option, to my preferences, this can be used
---in an autocommand to set the `vim.opt_local.colorcolumn` or by a plugin such as `virtcolumn.nvim`
---to set it's virtual column
---@param bufnr integer
---@param fn fun(colorcolumn: string | boolean)
function ar.ui.decorations.set_colorcolumn(bufnr, fn)
  local buf = vim.bo[bufnr]
  local decor = ar.ui.decorations.get({
    ft = buf.ft,
    bt = buf.bt,
    setting = 'colorcolumn',
  })
  local ccol = ''
  if decor and not ar.falsy(decor) then ccol = decor.ft or decor.bt or '' end
  local colorcolumn = not ar.falsy(ccol) and ccol or '+1'
  if buf.ft == '' or buf.bt ~= '' then colorcolumn = '' end
  if vim.is_callable(fn) then fn(colorcolumn) end
end

--------------------------------------------------------------------------------
-- The current styles for various UI elements
ar.ui.current = { border = ar.ui.border.line }
