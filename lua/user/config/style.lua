rvim.style = {
  border = {
    common = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    line = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
    rectangle = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
  },
  icons = {
    separators = {
      vert_bottom_half_block = '▄',
      vert_top_half_block = '▀',
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
  },
  codicons = {
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
  },
}

----------------------------------------------------------------------------------------------------
-- Global style settings
----------------------------------------------------------------------------------------------------
-- Some styles can be tweak here to apply globally i.e. by setting the current value for that style
-- The current styles for various UI elements
rvim.style.current = {
  border = rvim.style.border.line,
  lsp_icons = rvim.style.codicons.kind,
}
