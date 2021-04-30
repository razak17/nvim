local M = {}
local vim = vim

local chain_complete_list = {
    default = {{
        complete_items = {
            'lsp',
            'ts',
            'snippet',
            'buffers'
        }
    }, {
        complete_items = {'path'},
        triggered_only = {'/'}
    }, {
        complete_items = {'buffers'}
    }},
    string = {{
        complete_items = {'path'},
        triggered_only = {'/'}
    }},
    comment = {},
    sql = {{
        complete_items = {
            'vim-dadbod-completion',
            'lsp'
        }
    }},
    vim = {{
        complete_items = {'snippet'}
    }, {
        mode = {'cmd'}
    }}
}

M.chain_complete_list = chain_complete_list

function M.setup()
  -- Completion Nvim settings
  vim.g.completion_confirm_key = ""
  vim.g.completion_enable_snippet = 'UltiSnips'
  vim.g.completion_enable_auto_signature = 1
  vim.g.completion_auto_change_source = 1
  vim.g.completion_trigger_on_delete = 1
  vim.g.completion_matching_ignore_case = 1
  -- vim.g.completion_matching_smart_case = 1
  vim.g.completion_timer_cycle = 20
  vim.g.completion_enable_auto_hover = 0
  vim.g.completion_customize_lsp_label = {
      Function = "",
      Method = "",
      Variable = "",
      Constant = "",
      Class = "",
      Interface = "禍",
      Struct = "禍",
      Text = "",
      Enum = "",
      EnumMember = "",
      Module = "",
      Color = "",
      Property = "襁",
      Field = "綠",
      Unit = "",
      File = "",
      Value = "",
      Event = "鬒",
      Folder = "",
      Keyword = "",
      Snippet = "",
      Operator = "洛",
      Reference = " ",
      TypeParameter = "",
      Default = ""
  }
end

return M
