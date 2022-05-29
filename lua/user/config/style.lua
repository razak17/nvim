local borders = {
  telescope = {
    prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    ui_select = {
      { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
  },
  line = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
  rectangle = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
}

rvim.style = {
  border = vim.tbl_extend("force", borders, { current = borders.line }),
  icons = {
    lsp = {
      error = "",
      warn = "",
      info = "",
      hint = "",
    },
    statusline = {
      bar = "▊",
      mode = "",
    },
    git = {
      branch = "",
      added = "",
      mod = "",
      removed = "",
      ignore = "",
      rename = "",
      diff = "",
      repo = "",
    },
    documents = {
      file = "",
      files = "",
      folder = "",
      open_folder = "",
    },
    type = {
      array = "",
      number = "",
      object = "",
    },
    misc = {
      ellipsis = '…',
      up = '⇡',
      down = '⇣',
      line = 'ℓ', -- ''
      indent = 'Ξ',
      tab = '⇥',
      dap_red = "🛑",
      dap_hollow = "🟢",
      bug = "",
      bug_alt = "",
      question = "",
      lock = "",
      circle = "",
      dot = "•",
      project = "",
      dashboard = "",
      history = "",
      comment = "",
      robot = "ﮧ",
      lightbulb = "",
      search = "",
      code = "",
      telescope = "",
      gear = "",
      package = "",
      list = "",
      sign_in = "",
      check = "",
      fire = "",
      note = "",
      bookmark = "",
      pencil = "",
      chevron_right = "",
      chevron_right_alt = "❯",
      double_chevron_right = "»",
      table = "",
      calendar = "",
      tree = "",
    },
    kind = {
      Class = "", -- '',
      Color = " ",
      Constant = "", -- '',ﲀ
      Constructor = " ",
      Enum = "練",
      EnumMember = " ",
      Event = " ",
      Field = "", -- '',
      File = "",
      Folder = " ",
      Function = " ",
      Interface = "ﰮ ",
      Keyword = "", -- '',
      Method = " ",
      Module = " ",
      Operator = "",
      Property = " ",
      Reference = "", -- '',
      Snippet = "", -- '', '',
      Struct = "", -- 'פּ',
      Text = " ",
      TypeParameter = " ",
      Unit = "塞",
      Value = " ",
      Variable = "", -- '',
    },
  },
}

----------------------------------------------------------------------------------------------------
-- Global style settings
----------------------------------------------------------------------------------------------------
-- Some styles can be tweak here to apply globally i.e. by setting the current value for that style

rvim.style.border.current = rvim.style.border.line
